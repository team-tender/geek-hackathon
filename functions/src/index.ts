import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {defineString} from "firebase-functions/params";
import OpenAI from "openai";
import {createApi} from "unsplash-js";

// --- 使用する秘密情報を定義 ---
const OPENAI_API_KEY = defineString("OPENAI_API_KEY");
const UNSPLASH_ACCESS_KEY = defineString("UNSPLASH_ACCESS_KEY");

// --- 言語コードを言語名に変換するヘルパー関数 ---
const getLanguageName = (code: string | undefined): string => {
  switch (code) {
  case "en":
    return "English";
  case "ja":
    return "Japanese";
  case "ko":
    return "Korean";
  case "zh":
    return "Chinese";
  case "es":
    return "Spanish";
  case "fr":
    return "French";
  default:
    return "Japanese"; // 不明な場合は日本語をデフォルトにする
  }
};

// --- API 1: アキネーター風の質問を生成する関数 ---
export const getTravelQuestion = onRequest(
  {cors: true, secrets: [OPENAI_API_KEY]},
  async (req, res) => {
    const openai = new OpenAI({
      apiKey: OPENAI_API_KEY.value(),
    });

    const previousAnswers = req.body.data?.answers || [];
    const languageCode = req.body.data?.language;
    const language = getLanguageName(languageCode);

    if (!Array.isArray(previousAnswers)) {
      logger.error("不正なリクエストボディです:", req.body);
      res.status(400).json({error: {message: "不正なリクエスト形式です。"}});
      return;
    }
    logger.info("過去の回答: ", previousAnswers);

    const prompt = `
      あなたは優秀な旅行プランナーです。ユーザーの好みを知るために、
      アキネーター風に旅行先を絞り込む質問をしてください。
      以下のルールに従ってください。
      - 質問は常に1つだけ生成してください。
      - 回答は「はい」「いいえ」「わからない」「たぶんそう」の4択で答えられる形式にしてください。
      - ユーザーの過去の回答履歴を参考に、次の質問を生成してください。
      - 回答履歴がない場合は、最初の質問としてください。
      - 日本国内の旅行先を想定してください。
      - 生成する質問は必ず「${language}」にしてください。
      
      過去の回答履歴:
      ${previousAnswers.join("\n")}

      次の質問:
    `;

    try {
      const completion = await openai.chat.completions.create({
        model: "gpt-4o",
        messages: [{role: "user", content: prompt}],
      });

      const question = completion.choices[0].message.content;
      logger.info("生成された質問: ", question);
      res.json({data: {question: question}});
    } catch (error) {
      logger.error("OpenAI APIエラー:", error);
      res.status(500).json({error: {message: "質問の生成に失敗しました。"}});
    }
  },
);

// --- API 2: おすすめの旅行先を提案する関数 ---
export const getTravelDestination = onRequest(
  {cors: true, secrets: [OPENAI_API_KEY, UNSPLASH_ACCESS_KEY]},
  async (req, res) => {
    const openai = new OpenAI({apiKey: OPENAI_API_KEY.value()});
    const unsplash = createApi({accessKey: UNSPLASH_ACCESS_KEY.value()});

    const answers = req.body.data?.answers;
    const languageCode = req.body.data?.language;
    const language = getLanguageName(languageCode);

    if (!answers || !Array.isArray(answers) || answers.length === 0) {
      return;
    }
    logger.info("最終的な回答リスト: ", answers);

    const locationsPrompt = `
      ユーザーの以下の回答履歴を元に、最もおすすめの日本の旅行先の候補を5つ提案してください。
      都道府県名のような広域な地名ではなく、より具体的な地名（例：都市名、有名な観光地名など）を提案してください。
      回答は {"locations": ["地名1", "地名2", "地名3", "地名4", "地名5"]} というJSONオブジェクトの形式で、
      locationsというキーに地名の配列を入れて返してください。
      例: {"locations": ["箱根", "軽井沢", "別府温泉", "伊勢志摩", "金沢"]}
      地名は必ず「${language}」で返してください。

      回答履歴:
      ${answers.join("\n")}
    `;

    try {
      const locationCompletion = await openai.chat.completions.create({
        model: "gpt-4o",
        response_format: {type: "json_object"},
        messages: [
          {
            role: "system",
            content: "You are a helpful assistant designed to output JSON.",
          },
          {role: "user", content: locationsPrompt},
        ],
      });

      const messageContent = locationCompletion.choices[0].message.content;
      if (!messageContent) {
        throw new Error("OpenAIからのレスポンスが空です。");
      }

      const parsedContent = JSON.parse(messageContent);
      const locationNames = parsedContent.locations ||
        Object.values(parsedContent).find(Array.isArray);

      if (!Array.isArray(locationNames)) {
        logger.error("期待した形式の配列が見つかりませんでした。", parsedContent);
        throw new Error("旅行先のリスト取得に失敗しました。");
      }

      logger.info("提案された旅行先リスト: ", locationNames);

      const destinationPromises = locationNames.map(async (name: string) => {
        const [
          photoResult,
          descriptionResult,
          accessResult,
        ] = await Promise.all([
          unsplash.search.getPhotos({
            query: `${name} japan`,
            perPage: 1,
            orientation: "landscape",
          }),
          openai.chat.completions.create({
            model: "gpt-4o",
            messages: [{
              role: "user",
              content: `日本の「${name}」について、
                       150文字程度の魅力的な説明文を「${language}」で作成してください。`,
            }],
          }),
          openai.chat.completions.create({
            model: "gpt-4o",
            messages: [{
              role: "user",
              content: `東京駅から日本の「${name}」への主なアクセス方法を
                        100文字程度で簡潔に「${language}」で説明してください。`,
            }],
          }),
        ]);

        return {
          name: name,
          description: descriptionResult.choices[0].message.content,
          access: accessResult.choices[0].message.content,
          imageUrl: photoResult.response?.results[0]?.urls?.regular || null,
        };
      });

      const destinations = await Promise.all(destinationPromises);
      res.json({data: {destinations: destinations}});
    } catch (error) {
      logger.error("旅行先の提案エラー:", error);
      res.status(500).json({error: {message: "旅行先の提案に失敗しました。"}});
    }
  },
);

// --- API 3: ランダムな旅行先を提案する新しい関数 ---
export const getRandomDestinations = onRequest(
  {cors: true, secrets: [OPENAI_API_KEY, UNSPLASH_ACCESS_KEY]},
  async (req, res) => {
    const openai = new OpenAI({apiKey: OPENAI_API_KEY.value()});
    const unsplash = createApi({accessKey: UNSPLASH_ACCESS_KEY.value()});

    const languageCode = req.body.data?.language;
    const language = getLanguageName(languageCode);
    logger.info(`Getting random destinations in ${language}`);

    const locationsPrompt = `
      日本の人気で具体的な旅行先（都市名や有名な観光地名）をランダムに5つ提案してください。
      回答は {"locations": ["地名1", "地名2", "地名3", "地名4", "地名5"]} というJSONオブジェクトの形式で、
      locationsというキーに地名の配列を入れて返してください。
      例: {"locations": ["札幌", "横浜", "福岡", "草津温泉", "石垣島"]}
      地名は必ず「${language}」で返してください。
    `;

    try {
      const locationCompletion = await openai.chat.completions.create({
        model: "gpt-4o",
        response_format: {type: "json_object"},
        messages: [
          {
            role: "system",
            content: "You are a helpful assistant designed to output JSON.",
          },
          {role: "user", content: locationsPrompt},
        ],
      });

      const messageContent = locationCompletion.choices[0].message.content;
      if (!messageContent) {
        throw new Error("OpenAIからのレスポンスが空です。");
      }

      const parsedContent = JSON.parse(messageContent);
      const locationNames = parsedContent.locations ||
        Object.values(parsedContent).find(Array.isArray);

      if (!Array.isArray(locationNames)) {
        logger.error("期待した形式の配列が見つかりませんでした。", parsedContent);
        throw new Error("旅行先のリスト取得に失敗しました。");
      }

      logger.info("提案されたランダムな旅行先リスト: ", locationNames);

      const destinationPromises = locationNames.map(async (name: string) => {
        const [
          photoResult,
          descriptionResult,
          accessResult,
        ] = await Promise.all([
          unsplash.search.getPhotos({
            query: `${name} japan`,
            perPage: 1,
            orientation: "landscape",
          }),
          openai.chat.completions.create({
            model: "gpt-4o",
            messages: [{
              role: "user",
              content: `日本の「${name}」について、150文字程度の魅力的な説明文を
                        「${language}」で作成してください。`,
            }],
          }),
          openai.chat.completions.create({
            model: "gpt-4o",
            messages: [{
              role: "user",
              content: `東京駅から日本の「${name}」への主なアクセス方法を
                        100文字程度で簡潔に「${language}」で説明してください。`,
            }],
          }),
        ]);

        return {
          name: name,
          description: descriptionResult.choices[0].message.content,
          access: accessResult.choices[0].message.content,
          imageUrl: photoResult.response?.results[0]?.urls?.regular || null,
        };
      });

      const destinations = await Promise.all(destinationPromises);
      res.json({data: {destinations: destinations}});
    } catch (error) {
      logger.error("ランダムな旅行先の提案エラー:", error);
      res.status(500).json({error: {message: "ランダムな旅行先の提案に失敗しました。"}});
    }
  },
);
