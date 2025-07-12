## 🚀 開発開始手順

以下の手順でローカル環境にプロジェクトをセットアップし、開発を開始できます。

### 1. リポジトリをクローン

```bash
git clone https://github.com/team-tender/geek-hackathon.git
cd geek-hackathon
```
### 2. Flutter バージョンの統一（fvm 使用）

```bash
fvm install 3.32.5
fvm use 3.32.5
```

### 3. 依存パッケージの取得

```bash
flutter pub get
```

### 4. コード整形・Lint用の Git Hook を有効化（pre-commit 使用）

```bash
brew install pre-commit  # macOS の場合
pip install pre-commit   # Windows の場合
pre-commit install
```
### 5. 開発ブランチを作成

```bash
git checkout -b feature/your-feature-name
```

### 6. アプリを実行

```bash
flutter run
```

## 📁 ディレクトリ構成（MVVM）

このプロジェクトでは、MVVM アーキテクチャに基づいて以下のような構成を採用しています。

- `main.dart`  
  アプリケーションのエントリーポイントです。

- `app.dart`  
  `MaterialApp` の設定やルーティング初期化など、アプリ全体の設定を行います。

- `core/`  
  アプリケーション全体で使用する定数やユーティリティ関数などの共通コードを格納します。
    - `constants.dart`: APIエンドポイントや文字列などの定数を定義します。
    - `utils.dart`: 共通で使われるヘルパー関数などを記述します。

- `data/`  
  データに関する責務を持つ層です。モデル定義やリポジトリを配置します。
    - `models/`: API レスポンスやローカルデータを扱うデータモデルを定義します。
    - `repositories/`: データ取得ロジック（API・DB）を抽象化して定義します。
      - `app_repository.dart` は全体のデータ取得を管理します。

- `presentation/`  
  UI や状態管理（ViewModel）を含むプレゼンテーション層です。
    - `common/`: ローディングインジケータや共通の UI コンポーネントを配置します。
    - `routes.dart`: 画面遷移（Navigator）に必要なルーティング設定を記述します。
    - `screens/`: 各画面ごとの UI (`xxx_screen.dart`) と状態管理 (`xxx_viewmodel.dart`) をまとめて配置します。
      - 例: `home/`, `detail/` など
    - `widgets/`: 画面に依存しない、再利用可能な UI コンポーネントを配置します
