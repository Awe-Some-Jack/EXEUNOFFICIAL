import java.io.File;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import javafx.animation.Animation;
import javafx.animation.FadeTransition;
import javafx.animation.KeyFrame;
import javafx.animation.KeyValue;
import javafx.animation.ParallelTransition;
import javafx.animation.PauseTransition;
import javafx.animation.RotateTransition;
import javafx.animation.ScaleTransition;
import javafx.animation.SequentialTransition;
import javafx.animation.Timeline;
import javafx.application.Application;
import javafx.concurrent.Task;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.ProgressBar;
import javafx.scene.effect.Glow;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.*;
import javafx.scene.media.Media;
import javafx.scene.media.MediaPlayer;
import javafx.scene.paint.Color;
import javafx.scene.shape.Polygon;
import javafx.scene.control.ProgressIndicator;
import javafx.scene.text.Font;
import javafx.scene.text.Text;
import javafx.scene.text.TextFlow;
import javafx.stage.Stage;
import javafx.stage.StageStyle;
import javafx.util.Duration;

public class MainLauncher extends Application {

    private double xOffset = 0;
    private double yOffset = 0;

    private List<Image> gameplayImages = new ArrayList<>();
    private int currentImageIndex = 0;

    private Button btnUpdate;
    private Button btnStartGame;
    private Font pressStartFontText;

    private ProgressBar launchProgressBar;
    private ProgressBar updateProgressBar;

    private VBox launchGroup;
    private VBox updateGroup;

    private Text titleAboutText;
    private VBox aboutBoxContainer;
    private Text launchTitleText;
    private Text updateTitleText;
    private TextFlow launchStatsFlow;
    private TextFlow updateStatsFlow;

    private StackPane overlayPane;
    private VBox settingsCard;
    private Text langLabel;
    private int currentLangIndex = 0;

    private StackPane warningOverlayPane;
    private VBox warningCard;
    private Text warningTitleText;
    private TextFlow warningTextFlow;

    private StackPane searchOverlayPane;
    private VBox searchCard;
    private Text searchTitleText;
    private VBox searchContentBox;
    private ProgressIndicator spinnerIndicator;

    private StackPane installLocationOverlayPane;
    private VBox installLocationCard;
    private Text installPathDisplay;
    private File selectedDirectoryToInstall;

    private MediaPlayer helpMediaPlayer;
    private ImageView popupImageView;
    private SequentialTransition popupSequence;

    private boolean isGameInstalled = false;
    private boolean isActionInProgress = false;

    private final double INACTIVE_ALPHA = 0.67;
    private final String REPO_OWNER = "cocoCode17";
    private final String REPO_NAME = "FNF-Vs-Sonic.EXE-Unofficial-Releases";

    private String STYLE_CSS_PATH = "media/data/style.css";

    @Override
    public void start(Stage primaryStage) {
        primaryStage.initStyle(StageStyle.TRANSPARENT);

        LanguageManager.scanAvailableLanguages();
        String savedLang = LanguageManager.getSavedLanguage();
        LanguageManager.loadLanguage(savedLang);

        checkGameInstallation();

        File fontFile = new File("media/fonts/PressStart2P.ttf");
        if (fontFile.exists()) {
            try (java.io.FileInputStream fontStream = new java.io.FileInputStream(fontFile)) {
                pressStartFontText = Font.loadFont(fontStream, 12);
            } catch (Exception e) {
                System.out.println("Error loading font: " + e.getMessage());
            }
        }

        preloadHelpSound();

        BorderPane header = new BorderPane();
        header.getStyleClass().add("custom-header");

        header.setOnMousePressed(event -> {
            xOffset = event.getSceneX();
            yOffset = event.getSceneY();
        });
        header.setOnMouseDragged(event -> {
            primaryStage.setX(event.getScreenX() - xOffset);
            primaryStage.setY(event.getScreenY() - yOffset);
        });

        HBox socialContainer = new HBox(20);
        socialContainer.getStyleClass().add("button-box");
        socialContainer.setAlignment(Pos.CENTER);

        Button btnDiscord  = createIconButtonWithImage("media/header/discord.png", "icon-btn", 24);
        Button btnWeb      = createIconButtonWithImage("media/header/web.png", "icon-btn", 24);
        Button btnGameJolt = createIconButtonWithImage("media/header/gamejolt.png", "icon-btn", 24);
        Button btnItchIO   = createIconButtonWithImage("media/header/itch io.png", "icon-btn", 24);

        btnDiscord.setOnAction(e -> getHostServices().showDocument("https://discord.gg/PuUWqKbfgX"));
        btnWeb.setOnAction(e -> getHostServices().showDocument("https://vsexeunofficial.com/"));
        btnGameJolt.setOnAction(e -> getHostServices().showDocument("https://gamejolt.com/games/exeunofficial/1055030"));
        btnItchIO.setOnAction(e -> getHostServices().showDocument("https://dudugd20.itch.io/vs-sonicexe-unofficial"));

        socialContainer.getChildren().addAll(btnDiscord, btnWeb, btnGameJolt, btnItchIO);
        header.setLeft(socialContainer);

        HBox controlContainer = new HBox(20);
        controlContainer.getStyleClass().add("button-box");
        controlContainer.setAlignment(Pos.CENTER);
        controlContainer.setTranslateY(-5);

        Button btnSettings = createIconButtonWithImage("media/header/configButton.png", "icon-btn", 24);
        Button btnMinimize = createIconButtonWithImage("media/header/minimizeButton.png", "icon-btn", 24);
        Button btnClose    = createIconButtonWithImage("media/header/closeButton.png", "close-btn", 24);

        btnSettings.setOnAction(e -> openSettingsOverlay());
        btnMinimize.setOnAction(e -> primaryStage.setIconified(true));
        btnClose.setOnAction(e -> primaryStage.close());

        controlContainer.getChildren().addAll(btnSettings, btnMinimize, btnClose);
        header.setRight(controlContainer);

        HBox mainContent = new HBox(20);
        mainContent.getStyleClass().add("main-content");
        
        aboutBoxContainer = createAboutSection();
        HBox.setHgrow(aboutBoxContainer, Priority.ALWAYS);

        VBox rightSide = new VBox(20);
        rightSide.setAlignment(Pos.TOP_RIGHT);

        StackPane gameplayContainer = createGameplayViewer();
        HBox actionButtonsBox = createActionButtons(primaryStage);

        rightSide.getChildren().addAll(gameplayContainer, actionButtonsBox);
        mainContent.getChildren().addAll(aboutBoxContainer, rightSide);

        VBox mainBox = new VBox();
        mainBox.getStyleClass().add("main-window");
        mainBox.setPrefSize(935, 411);
        mainBox.setMaxSize(935, 411);
        mainBox.getChildren().addAll(header, mainContent);

        double width = 935;
        double height = 411;
        double cutSize = 45;

        Polygon clipPath = new Polygon(
            0, 0,
            width - cutSize, 0,
            width, cutSize,
            width, height,
            0, height
        );
        mainBox.setClip(clipPath);

        ImageView logoView = new ImageView();
        File logoFile = new File("media/header/logo.png");
        if (logoFile.exists()) {
            Image logoImg = new Image(logoFile.toURI().toString());
            logoView.setImage(logoImg);
            logoView.setPreserveRatio(true);
            logoView.setFitHeight(290.95);
        }
        logoView.setPickOnBounds(false);

        overlayPane = createSettingsOverlay(width, height, cutSize);
        warningOverlayPane = createWarningOverlay(width, height, cutSize);
        searchOverlayPane = createSearchUpdateOverlay(width, height, cutSize);
        installLocationOverlayPane = createInstallLocationOverlay(width, height, cutSize, primaryStage);

        popupImageView = new ImageView();
        File imgFile = new File("media/settings/assmanxd.png");
        if (imgFile.exists()) {
            popupImageView.setImage(new Image(imgFile.toURI().toString()));
        }
        popupImageView.setPreserveRatio(true);
        popupImageView.setFitWidth(300);
        popupImageView.setOpacity(0.0);
        popupImageView.setVisible(false);
        popupImageView.setTranslateY(20);

        StackPane root = new StackPane();
        root.setStyle("-fx-background-color: transparent;");

        root.getChildren().addAll(mainBox, overlayPane, warningOverlayPane, searchOverlayPane, installLocationOverlayPane, logoView, popupImageView);

        StackPane.setAlignment(mainBox, Pos.TOP_CENTER);
        StackPane.setAlignment(overlayPane, Pos.TOP_CENTER);
        StackPane.setAlignment(warningOverlayPane, Pos.TOP_CENTER);
        StackPane.setAlignment(searchOverlayPane, Pos.TOP_CENTER);
        StackPane.setAlignment(installLocationOverlayPane, Pos.TOP_CENTER);
        StackPane.setAlignment(logoView, Pos.TOP_CENTER);
        StackPane.setAlignment(popupImageView, Pos.CENTER);

        StackPane.setMargin(mainBox, new javafx.geometry.Insets(140, 0, 0, 0));
        StackPane.setMargin(overlayPane, new javafx.geometry.Insets(140, 0, 0, 0));
        StackPane.setMargin(warningOverlayPane, new javafx.geometry.Insets(140, 0, 0, 0));
        StackPane.setMargin(searchOverlayPane, new javafx.geometry.Insets(140, 0, 0, 0));
        StackPane.setMargin(installLocationOverlayPane, new javafx.geometry.Insets(140, 0, 0, 0));
        logoView.setTranslateY(-10);

        Scene scene = new Scene(root, 950, 580);
        scene.setFill(Color.TRANSPARENT);

        if (getClass().getResource(STYLE_CSS_PATH) != null) {
            scene.getStylesheets().add(getClass().getResource(STYLE_CSS_PATH).toExternalForm());
        }

        File iconFile = new File("icons/iconOG.png");
        if (iconFile.exists()) {
            primaryStage.getIcons().add(new Image(iconFile.toURI().toString()));
        }

        primaryStage.setScene(scene);
        primaryStage.setTitle("Friday Night Funkin': VS Sonic.EXE (Unofficial) - Launcher");
        primaryStage.show();

        updateButtonStates();
    }

    private void checkGameInstallation() {
        File gameExe = InstallManager.getGameExecutable();
        isGameInstalled = gameExe.exists();
        if (!isGameInstalled) {
            InstallManager.resetToDefaultDirectory();
        }
    }

    private void updateButtonStates() {
        if (btnStartGame != null) {
            String labelKey = isGameInstalled ? "btn_start_game" : "btn_install";
            updateButtonLabel(btnStartGame, LanguageManager.get(labelKey));
        }

        if (launchTitleText != null) {
            String titleKey = isGameInstalled ? "launch_progress" : "install_progress";
            launchTitleText.setText(LanguageManager.get(titleKey));
        }

        if (btnUpdate != null) {
            if (!isGameInstalled) {
                btnUpdate.setDisable(true);
                btnUpdate.getStyleClass().add("action-btn-disabled");
            } else {
                btnUpdate.setDisable(false);
                btnUpdate.getStyleClass().remove("action-btn-disabled");
            }
        }

        if (!isActionInProgress) {
            if (launchGroup != null) launchGroup.setOpacity(INACTIVE_ALPHA);
            if (updateGroup != null) updateGroup.setOpacity(INACTIVE_ALPHA);

            if (launchTitleText != null) launchTitleText.setVisible(false);
            if (launchStatsFlow != null) launchStatsFlow.setVisible(false);
            if (updateTitleText != null) updateTitleText.setVisible(false);
            if (updateStatsFlow != null) updateStatsFlow.setVisible(false);

            if (launchProgressBar != null) launchProgressBar.setProgress(0);
            if (updateProgressBar != null) updateProgressBar.setProgress(0);
        }
    }

    private void preloadHelpSound() {
        File folder = new File("media/sounds");
        if (folder.exists() && folder.isDirectory()) {
            File[] files = folder.listFiles((dir, name) -> 
                name.toLowerCase().endsWith(".wav") || 
                name.toLowerCase().endsWith(".mp3") || 
                name.toLowerCase().endsWith(".m4a")
            );
            if (files != null && files.length > 0) {
                try {
                    Media sound = new Media(files[0].toURI().toString());
                    helpMediaPlayer = new MediaPlayer(sound);
                    helpMediaPlayer.setStartTime(Duration.seconds(0.5));
                } catch (Exception e) {
                    System.out.println("Error precaching snd: " + e.getMessage());
                }
            }
        }
    }

    private VBox createAboutSection() {
        VBox box = new VBox(10);
        box.getStyleClass().add("about-box");
        box.setMaxWidth(466);

        titleAboutText = new Text(LanguageManager.get("about_title"));
        titleAboutText.getStyleClass().add("about-title");
        titleAboutText.setTranslateY(15);
        titleAboutText.setTranslateX(8);

        TextFlow descriptionFlow = LanguageManager.parseFormattedText("about_text");
        descriptionFlow.setPrefWidth(466);
        descriptionFlow.setTranslateY(25);
        descriptionFlow.setLineSpacing(8);

        VBox progressContainer = createProgressBarsSection();
        progressContainer.setTranslateY(45);
        progressContainer.setTranslateX(8);

        box.getChildren().addAll(titleAboutText, descriptionFlow, progressContainer);
        return box;
    }

    private VBox createProgressBarsSection() {
        int progressOffsets = 20;
        VBox progressBox = new VBox(12);

        launchGroup = new VBox(4);
        BorderPane launchHeader = new BorderPane();
        
        String titleKey = isGameInstalled ? "launch_progress" : "install_progress";
        launchTitleText = new Text(LanguageManager.get(titleKey));
        launchTitleText.getStyleClass().add("progress-title");
        launchTitleText.setTranslateX(-8);
        launchTitleText.setVisible(false);

        launchStatsFlow = formatStatsText("0%", "[0Mb of 0MB]");
        launchStatsFlow.setVisible(false);

        launchHeader.setLeft(launchTitleText);
        launchHeader.setRight(launchStatsFlow);
        launchHeader.setTranslateY(progressOffsets - 12);

        launchProgressBar = new ProgressBar(0);
        launchProgressBar.getStyleClass().add("launch-progress-bar");
        launchProgressBar.setPrefWidth(466);
        launchProgressBar.setMaxWidth(466);
        launchProgressBar.setTranslateX(-10);
        launchProgressBar.setTranslateY(progressOffsets - 4);

        launchGroup.getChildren().addAll(launchHeader, launchProgressBar);
        launchGroup.setOpacity(INACTIVE_ALPHA);

        updateGroup = new VBox(4);
        BorderPane updateHeader = new BorderPane();
        updateTitleText = new Text(LanguageManager.get("update_progress"));
        updateTitleText.getStyleClass().add("progress-title");
        updateTitleText.setTranslateX(-8);
        updateTitleText.setVisible(false);

        updateStatsFlow = formatStatsText("0%", "[0Mb of 0MB]");
        updateStatsFlow.setVisible(false);

        updateHeader.setLeft(updateTitleText);
        updateHeader.setRight(updateStatsFlow);
        updateHeader.setTranslateY(progressOffsets + 4);

        updateProgressBar = new ProgressBar(0);
        updateProgressBar.getStyleClass().add("update-progress-bar");
        updateProgressBar.setPrefWidth(466);
        updateProgressBar.setMaxWidth(466);

        updateGroup.getChildren().addAll(updateHeader, updateProgressBar);
        updateProgressBar.setTranslateX(-10);
        updateProgressBar.setTranslateY(progressOffsets + 10);
        updateGroup.setOpacity(INACTIVE_ALPHA);

        progressBox.getChildren().addAll(launchGroup, updateGroup);
        return progressBox;
    }

    private TextFlow formatStatsText(String percent, String bracketContent) {
        TextFlow flow = new TextFlow();

        Text percentText = new Text(percent + " ");
        percentText.getStyleClass().add("stats-percent");
        flow.getChildren().add(percentText);

        if (bracketContent.contains(" of ")) {
            String[] parts = bracketContent.split(" of ");
            Text part1 = new Text(parts[0] + " ");
            part1.getStyleClass().add("stats-cyan");

            Text wordOf = new Text("of ");
            wordOf.getStyleClass().add("stats-of-gray");

            Text part2 = new Text(parts[1]);
            part2.getStyleClass().add("stats-cyan");

            flow.getChildren().addAll(part1, wordOf, part2);
        } else {
            Text bracketText = new Text(bracketContent);
            bracketText.getStyleClass().add("stats-cyan");
            flow.getChildren().add(bracketText);
        }

        return flow;
    }

    private void updateStatsFlowText(TextFlow targetFlow, String percent, String bracketContent) {
        targetFlow.getChildren().clear();
        TextFlow newFlow = formatStatsText(percent, bracketContent);
        targetFlow.getChildren().addAll(newFlow.getChildren());
    }

    private StackPane createSettingsOverlay(double width, double height, double cutSize) {
        StackPane overlay = new StackPane();
        overlay.getStyleClass().add("settings-overlay");
        overlay.setPrefSize(width, height);
        overlay.setMaxSize(width, height);
        overlay.setMinSize(width, height);
        overlay.setVisible(false);
        overlay.setOpacity(0.0);

        Polygon clipPath = new Polygon(
            0, 0,
            width - cutSize, 0,
            width, cutSize,
            width, height,
            0, height
        );
        overlay.setClip(clipPath);

        overlay.setOnMouseClicked(e -> {
            if (e.getTarget() == overlay) {
                closeSettingsOverlay();
            }
        });

        settingsCard = new VBox(15);
        settingsCard.getStyleClass().add("settings-card");
        settingsCard.setAlignment(Pos.TOP_CENTER);
        settingsCard.setPrefSize(410, 145);
        settingsCard.setMaxSize(410, 145);

        Text cardTitle = new Text("SETTINGS");
        cardTitle.getStyleClass().add("settings-title");

        HBox langRow = new HBox(12);
        langRow.setAlignment(Pos.CENTER);

        Text langTag = new Text("LANGUAGE:");
        langTag.getStyleClass().add("settings-label");

        Button btnLeft = new Button("<");
        btnLeft.getStyleClass().add("arrow-btn");
        btnLeft.setOnAction(e -> changeLanguageIndex(-1));

        List<String> langs = LanguageManager.getAvailableLanguages();
        String currentCode = LanguageManager.getCurrentLangCode();
        currentLangIndex = langs.indexOf(currentCode);
        if (currentLangIndex < 0) currentLangIndex = 0;

        langLabel = new Text(LanguageManager.getLanguageDisplayName(langs.get(currentLangIndex)));
        langLabel.getStyleClass().add("lang-display");

        Button btnRight = new Button(">");
        btnRight.getStyleClass().add("arrow-btn");
        btnRight.setOnAction(e -> changeLanguageIndex(1));

        langRow.getChildren().addAll(langTag, btnLeft, langLabel, btnRight);

        BorderPane bottomBar = new BorderPane();
        bottomBar.setMaxWidth(370);

        int settaddY = 16;

        String helpIconPath = "media/settings/btnQue.png";
        Button btnHelp = createIconButtonWithImage(helpIconPath, "icon-btn", 22);
        btnHelp.setOnAction(e -> triggerHelpAction());
        btnHelp.setTranslateY(settaddY);

        Button btnCloseSettings = new Button("CLOSE");
        btnCloseSettings.getStyleClass().add("close-settings-btn");
        btnCloseSettings.setOnAction(e -> closeSettingsOverlay());
        btnCloseSettings.setTranslateY(settaddY);

        bottomBar.setLeft(btnHelp);
        bottomBar.setRight(btnCloseSettings);

        settingsCard.getChildren().addAll(cardTitle, langRow, bottomBar);
        overlay.getChildren().add(settingsCard);

        return overlay;
    }

    private StackPane createWarningOverlay(double width, double height, double cutSize) {
        StackPane overlay = new StackPane();
        overlay.getStyleClass().add("settings-overlay");
        overlay.setPrefSize(width, height);
        overlay.setMaxSize(width, height);
        overlay.setMinSize(width, height);
        overlay.setVisible(false);
        overlay.setOpacity(0.0);

        Polygon clipPath = new Polygon(
            0, 0,
            width - cutSize, 0,
            width, cutSize,
            width, height,
            0, height
        );
        overlay.setClip(clipPath);

        overlay.setOnMouseClicked(e -> {
            if (e.getTarget() == overlay) {
                closeWarningOverlay();
            }
        });

        warningCard = new VBox(15);
        warningCard.getStyleClass().add("warning-card");
        warningCard.setAlignment(Pos.TOP_CENTER);
        warningCard.setPrefSize(420, 200);
        warningCard.setMaxSize(420, 200);

        warningTitleText = new Text(LanguageManager.get("warning_title"));
        warningTitleText.getStyleClass().add("warning-title");
        warningTitleText.setTranslateY(20);

        warningTextFlow = LanguageManager.parseFormattedText("warning_text");
        warningTextFlow.setPrefWidth(380);
        warningTextFlow.getStyleClass().add("warning-text-container");
        warningTextFlow.setTranslateY(30);
        warningTextFlow.setScaleX(1.08);
        warningTextFlow.setScaleY(1.44);

        Button btnProceed = new Button("OK");
        btnProceed.getStyleClass().add("warning-ok-btn");
        btnProceed.setOnAction(e -> {
            closeWarningOverlay();
            proceedGameAction();
        });
        btnProceed.setTranslateY(40);

        warningCard.getChildren().addAll(warningTitleText, warningTextFlow, btnProceed);
        overlay.getChildren().add(warningCard);

        return overlay;
    }

    private StackPane createSearchUpdateOverlay(double width, double height, double cutSize) {
        StackPane overlay = new StackPane();
        overlay.getStyleClass().add("settings-overlay");
        overlay.setPrefSize(width, height);
        overlay.setMaxSize(width, height);
        overlay.setMinSize(width, height);
        overlay.setVisible(false);
        overlay.setOpacity(0.0);

        Polygon clipPath = new Polygon(
            0, 0,
            width - cutSize, 0,
            width, cutSize,
            width, height,
            0, height
        );
        overlay.setClip(clipPath);

        searchCard = new VBox(15);
        searchCard.getStyleClass().add("warning-card");
        searchCard.setAlignment(Pos.TOP_CENTER);
        searchCard.setPrefSize(420, 180);
        searchCard.setMaxSize(420, 180);

        searchTitleText = new Text(LanguageManager.get("search_updates_title"));
        searchTitleText.getStyleClass().add("warning-title");
        searchTitleText.setTranslateY(10);

        searchContentBox = new VBox(10);
        searchContentBox.setAlignment(Pos.CENTER);
        searchContentBox.setTranslateY(20);

        spinnerIndicator = new ProgressIndicator();
        spinnerIndicator.setPrefSize(35, 35);
        spinnerIndicator.setMaxSize(35, 35);
        spinnerIndicator.getStyleClass().add("red-spinner");
        spinnerIndicator.setScaleX(1.67);
        spinnerIndicator.setScaleY(1.67);
        spinnerIndicator.setTranslateY(14);
        searchContentBox.getChildren().add(spinnerIndicator);
        searchCard.getChildren().addAll(searchTitleText, searchContentBox);
        overlay.getChildren().add(searchCard);

        return overlay;
    }

    private Text installCardTitle;
    private Button btnCancel;
    private Button btnConfirmInstall;
    private StackPane createInstallLocationOverlay(double width, double height, double cutSize, Stage stage) {
        StackPane overlay = new StackPane();
        overlay.getStyleClass().add("settings-overlay");
        overlay.setPrefSize(width, height);
        overlay.setMaxSize(width, height);
        overlay.setMinSize(width, height);
        overlay.setVisible(false);
        overlay.setOpacity(0.0);

        Polygon clipPath = new Polygon(
            0, 0,
            width - cutSize, 0,
            width, cutSize,
            width, height,
            0, height
        );
        overlay.setClip(clipPath);

        int offsetaddY = -15;

        installLocationCard = new VBox(15);
        installLocationCard.getStyleClass().add("warning-card");
        installLocationCard.setAlignment(Pos.TOP_CENTER);
        installLocationCard.setPrefSize(440, 150);
        installLocationCard.setMaxSize(440, 150);
        installLocationCard.setTranslateY(offsetaddY);

        installCardTitle = new Text(LanguageManager.get("install_location"));
        installCardTitle.getStyleClass().add("settings-title");
        installCardTitle.setTranslateY(25+offsetaddY);

        selectedDirectoryToInstall = InstallManager.getInstallDirectory();

        installPathDisplay = new Text(selectedDirectoryToInstall.getAbsolutePath());
        installPathDisplay.getStyleClass().add("lang-display");
        installPathDisplay.setTranslateY(17);
        
        HBox pathRow = new HBox(10);
        pathRow.setAlignment(Pos.CENTER);

        Button btnBrowse = new Button("...");
        btnBrowse.getStyleClass().add("close-settings-btn");
        btnBrowse.setOnAction(e -> {
            javafx.stage.DirectoryChooser dc = new javafx.stage.DirectoryChooser();
            dc.setTitle("Select Installation Folder");
            if (selectedDirectoryToInstall.exists()) {
                dc.setInitialDirectory(selectedDirectoryToInstall.getParentFile() != null ? selectedDirectoryToInstall.getParentFile() : selectedDirectoryToInstall);
            }
            File chosen = dc.showDialog(stage);
            if (chosen != null) {
                File safeChoice = chosen.getName().equalsIgnoreCase("sonicexeunofficial") ? chosen : new File(chosen, "sonicexeunofficial");
                selectedDirectoryToInstall = safeChoice;
                installPathDisplay.setText(selectedDirectoryToInstall.getAbsolutePath());
            }
        });
        btnBrowse.setTranslateY(offsetaddY+32);

        pathRow.getChildren().addAll(installPathDisplay, btnBrowse);

        HBox actionsRow = new HBox(15);
        actionsRow.setAlignment(Pos.CENTER);
        actionsRow.setTranslateY(30);

        btnCancel = new Button(LanguageManager.get("install_cancel_label"));
        btnCancel.getStyleClass().add("close-settings-btn");
        btnCancel.setOnAction(e -> closeInstallLocationOverlay());
        btnCancel.setTranslateY(offsetaddY+5);

        btnConfirmInstall = new Button(LanguageManager.get("install_confirm_label"));
        btnConfirmInstall.getStyleClass().add("warning-ok-btn");
        btnConfirmInstall.setOnAction(e -> {
            InstallManager.setInstallDirectory(selectedDirectoryToInstall);
            closeInstallLocationOverlay();
            startInstallationProcess();
        });
        btnConfirmInstall.setTranslateY(offsetaddY+5);

        actionsRow.getChildren().addAll(btnCancel, btnConfirmInstall);

        installLocationCard.getChildren().addAll(installCardTitle, pathRow, actionsRow);
        overlay.getChildren().add(installLocationCard);

        return overlay;
    }

    private void openInstallLocationOverlay() {
        if (isActionInProgress) return;

        selectedDirectoryToInstall = InstallManager.getInstallDirectory();
        installPathDisplay.setText(selectedDirectoryToInstall.getAbsolutePath());

        installLocationOverlayPane.setVisible(true);
        installLocationCard.setScaleX(1.15);
        installLocationCard.setScaleY(1.15);

        FadeTransition ft = new FadeTransition(Duration.millis(200), installLocationOverlayPane);
        ft.setFromValue(0.0);
        ft.setToValue(1.0);

        Timeline bounceTimeline = new Timeline(
            new KeyFrame(Duration.ZERO, 
                new KeyValue(installLocationCard.scaleXProperty(), 1.15),
                new KeyValue(installLocationCard.scaleYProperty(), 1.15)
            ),
            new KeyFrame(Duration.millis(180), 
                new KeyValue(installLocationCard.scaleXProperty(), 0.95),
                new KeyValue(installLocationCard.scaleYProperty(), 0.95)
            ),
            new KeyFrame(Duration.millis(280), 
                new KeyValue(installLocationCard.scaleXProperty(), 1.03),
                new KeyValue(installLocationCard.scaleYProperty(), 1.03)
            ),
            new KeyFrame(Duration.millis(350), 
                new KeyValue(installLocationCard.scaleXProperty(), 1.0),
                new KeyValue(installLocationCard.scaleYProperty(), 1.0)
            )
        );

        ft.play();
        bounceTimeline.play();
    }

    private void closeInstallLocationOverlay() {
        FadeTransition ft = new FadeTransition(Duration.millis(150), installLocationOverlayPane);
        ft.setFromValue(1.0);
        ft.setToValue(0.0);
        ft.setOnFinished(e -> installLocationOverlayPane.setVisible(false));
        ft.play();
    }

    private void openWarningOverlay() {
        warningOverlayPane.setVisible(true);

        warningCard.setScaleX(1.15);
        warningCard.setScaleY(1.15);

        FadeTransition ft = new FadeTransition(Duration.millis(200), warningOverlayPane);
        ft.setFromValue(0.0);
        ft.setToValue(1.0);

        Timeline bounceTimeline = new Timeline(
            new KeyFrame(Duration.ZERO, 
                new KeyValue(warningCard.scaleXProperty(), 1.15),
                new KeyValue(warningCard.scaleYProperty(), 1.15)
            ),
            new KeyFrame(Duration.millis(180), 
                new KeyValue(warningCard.scaleXProperty(), 0.95),
                new KeyValue(warningCard.scaleYProperty(), 0.95)
            ),
            new KeyFrame(Duration.millis(280), 
                new KeyValue(warningCard.scaleXProperty(), 1.03),
                new KeyValue(warningCard.scaleYProperty(), 1.03)
            ),
            new KeyFrame(Duration.millis(350), 
                new KeyValue(warningCard.scaleXProperty(), 1.0),
                new KeyValue(warningCard.scaleYProperty(), 1.0)
            )
        );

        ft.play();
        bounceTimeline.play();
    }

    private void closeWarningOverlay() {
        FadeTransition ft = new FadeTransition(Duration.millis(150), warningOverlayPane);
        ft.setFromValue(1.0);
        ft.setToValue(0.0);
        ft.setOnFinished(e -> warningOverlayPane.setVisible(false));
        ft.play();
    }

    private void openSearchUpdateOverlay() {
        searchOverlayPane.setVisible(true);
        searchContentBox.getChildren().clear();
        searchContentBox.getChildren().add(spinnerIndicator);

        searchCard.setScaleX(1.15);
        searchCard.setScaleY(1.15);

        FadeTransition ft = new FadeTransition(Duration.millis(200), searchOverlayPane);
        ft.setFromValue(0.0);
        ft.setToValue(1.0);

        Timeline bounceTimeline = new Timeline(
            new KeyFrame(Duration.ZERO, 
                new KeyValue(searchCard.scaleXProperty(), 1.15),
                new KeyValue(searchCard.scaleYProperty(), 1.15)
            ),
            new KeyFrame(Duration.millis(180), 
                new KeyValue(searchCard.scaleXProperty(), 0.95),
                new KeyValue(searchCard.scaleYProperty(), 0.95)
            ),
            new KeyFrame(Duration.millis(280), 
                new KeyValue(searchCard.scaleXProperty(), 1.03),
                new KeyValue(searchCard.scaleYProperty(), 1.03)
            ),
            new KeyFrame(Duration.millis(350), 
                new KeyValue(searchCard.scaleXProperty(), 1.0),
                new KeyValue(searchCard.scaleYProperty(), 1.0)
            )
        );

        ft.play();
        bounceTimeline.play();
    }

    private void closeSearchUpdateOverlay() {
        FadeTransition ft = new FadeTransition(Duration.millis(150), searchOverlayPane);
        ft.setFromValue(1.0);
        ft.setToValue(0.0);
        ft.setOnFinished(e -> searchOverlayPane.setVisible(false));
        ft.play();
    }

    private void triggerHelpAction() {
        if (helpMediaPlayer != null) {
            helpMediaPlayer.stop();
            helpMediaPlayer.seek(Duration.seconds(0.5));
            helpMediaPlayer.play();
        } else {
            java.awt.Toolkit.getDefaultToolkit().beep();
        }

        if (popupSequence != null) {
            popupSequence.stop();
        }

        if (popupImageView != null && popupImageView.getImage() != null) {
            popupImageView.setVisible(true);

            popupImageView.setScaleX(0.7);
            popupImageView.setScaleY(0.7);
            popupImageView.setOpacity(0.0);

            FadeTransition fadeIn = new FadeTransition(Duration.millis(200), popupImageView);
            fadeIn.setFromValue(0.0);
            fadeIn.setToValue(1.0);

            ScaleTransition scaleIn = new ScaleTransition(Duration.millis(200), popupImageView);
            scaleIn.setFromX(0.7);
            scaleIn.setFromY(0.7);
            scaleIn.setToX(1.0);
            scaleIn.setToY(1.0);

            ParallelTransition step1 = new ParallelTransition(fadeIn, scaleIn);
            PauseTransition pause = new PauseTransition(Duration.seconds(0.25));

            ScaleTransition scaleOut = new ScaleTransition(Duration.millis(250), popupImageView);
            scaleOut.setFromX(1.0);
            scaleOut.setFromY(1.0);
            scaleOut.setToX(1.5);
            scaleOut.setToY(1.5);

            FadeTransition fadeOut = new FadeTransition(Duration.millis(250), popupImageView);
            fadeOut.setFromValue(1.0);
            fadeOut.setToValue(0.0);

            ParallelTransition step3 = new ParallelTransition(scaleOut, fadeOut);

            popupSequence = new SequentialTransition(step1, pause, step3);
            popupSequence.setOnFinished(e -> popupImageView.setVisible(false));
            popupSequence.play();
        }
    }

    private void changeLanguageIndex(int dir) {
        List<String> langs = LanguageManager.getAvailableLanguages();
        if (langs.isEmpty()) return;

        currentLangIndex = (currentLangIndex + dir + langs.size()) % langs.size();
        String selectedCode = langs.get(currentLangIndex);

        LanguageManager.loadLanguage(selectedCode);

        langLabel.setText(LanguageManager.getLanguageDisplayName(selectedCode));
        refreshLocalizedTexts();
    }

    private void refreshLocalizedTexts() {
        if (titleAboutText != null) titleAboutText.setText(LanguageManager.get("about_title"));
        if (launchTitleText != null) {
            String titleKey = isGameInstalled ? "launch_progress" : "install_progress";
            launchTitleText.setText(LanguageManager.get(titleKey));
        }
        if (updateTitleText != null) updateTitleText.setText(LanguageManager.get("update_progress"));
        if (warningTitleText != null) warningTitleText.setText(LanguageManager.get("warning_title"));
        if (searchTitleText != null) searchTitleText.setText(LanguageManager.get("search_updates_title"));
        if (installCardTitle != null) installCardTitle.setText(LanguageManager.get("install_location"));
      
        if (btnConfirmInstall != null)
            updateButtonLabel(btnConfirmInstall, LanguageManager.get("install_confirm_label"));
        if (btnCancel != null)
            updateButtonLabel(btnCancel, LanguageManager.get("install_cancel_label"));
       
        if (aboutBoxContainer != null) {
            aboutBoxContainer.getChildren().clear();
            VBox newBox = createAboutSection();
            aboutBoxContainer.getChildren().addAll(newBox.getChildren());
        }

        if (warningTextFlow != null) {
            warningTextFlow.getChildren().clear();
            TextFlow newWarningFlow = LanguageManager.parseFormattedText("warning_text");
            warningTextFlow.getChildren().addAll(newWarningFlow.getChildren());
        }

        if (btnUpdate != null) {
            updateButtonLabel(btnUpdate, LanguageManager.get("btn_update"));
        }
        
        updateButtonStates();
    }

    private void updateButtonLabel(Button btn, String text) {
        Node graphic = btn.getGraphic();
        if (graphic instanceof StackPane) {
            StackPane pane = (StackPane) graphic;
            for (Node child : pane.getChildren()) {
                if (child instanceof Text) {
                    ((Text) child).setText(text);
                    return;
                }
            }
        } else if (graphic instanceof Text) {
            ((Text) graphic).setText(text);
        } else {
            btn.setText(text);
        }
    }

    private void openSettingsOverlay() {
        if (isActionInProgress) return;
        overlayPane.setVisible(true);
        FadeTransition ft = new FadeTransition(Duration.millis(200), overlayPane);
        ft.setFromValue(0.0);
        ft.setToValue(1.0);
        ft.play();
    }

    private void closeSettingsOverlay() {
        FadeTransition ft = new FadeTransition(Duration.millis(150), overlayPane);
        ft.setFromValue(1.0);
        ft.setToValue(0.0);
        ft.setOnFinished(e -> overlayPane.setVisible(false));
        ft.play();
    }

    private StackPane createGameplayViewer() {
        StackPane frame = new StackPane();
        frame.getStyleClass().add("gameplay-frame");
        frame.setPrefSize(270, 153);
        frame.setMaxSize(270, 153);
        frame.setMinSize(270, 153);
        frame.setTranslateX(-25); 
        frame.setTranslateY(40);

        ImageView imageView = new ImageView();
        imageView.setFitWidth(270);
        imageView.setFitHeight(153);
        imageView.setPreserveRatio(false);

        javafx.scene.shape.Rectangle clip = new javafx.scene.shape.Rectangle(270, 153);
        clip.setArcWidth(6);
        clip.setArcHeight(6);
        imageView.setClip(clip);

        frame.getChildren().add(imageView);

        loadGameplayImages();

        if (!gameplayImages.isEmpty()) {
            imageView.setImage(gameplayImages.get(0));

            Timeline timeline = new Timeline(new KeyFrame(Duration.seconds(10), event -> {
                FadeTransition fadeOut = new FadeTransition(Duration.millis(600), imageView);
                fadeOut.setFromValue(1.0);
                fadeOut.setToValue(0.0);

                fadeOut.setOnFinished(e -> {
                    currentImageIndex = (currentImageIndex + 1) % gameplayImages.size();
                    imageView.setImage(gameplayImages.get(currentImageIndex));

                    FadeTransition fadeIn = new FadeTransition(Duration.millis(600), imageView);
                    fadeIn.setFromValue(0.0);
                    fadeIn.setToValue(1.0);
                    fadeIn.play();
                });

                fadeOut.play();
            }));

            timeline.setCycleCount(Timeline.INDEFINITE);
            timeline.play();
        }

        return frame;
    }

    private HBox createActionButtons(Stage primaryStage) {
        HBox box = new HBox(12);
        box.setAlignment(Pos.CENTER_RIGHT);
        box.setTranslateX(15);
        box.setTranslateY(80);

        btnUpdate = createCustomBoxButton(
            LanguageManager.get("btn_update"),
            "action-btn-update",
            "#424242"
        );
        btnUpdate.setOnAction(e -> {
            if (isGameInstalled && !isActionInProgress) {
                startUpdateSearchProcess();
            }
        });

        String initialStartLabel = isGameInstalled ? LanguageManager.get("btn_start_game") : LanguageManager.get("btn_install");
        btnStartGame = createCustomBoxButton(
            initialStartLabel,
            "action-btn-start",
            "#D32F2F"
        );
        btnStartGame.setOnAction(e -> {
            if (!isActionInProgress) {
                if (isGameInstalled) {
                    openWarningOverlay();
                } else {
                    proceedGameAction();
                }
            }
        });

        box.getChildren().addAll(btnUpdate, btnStartGame);
        return box;
    }

    private void proceedGameAction() {
        if (isGameInstalled) {
            startRealGameLaunch();
        } else {
            openInstallLocationOverlay();
        }
    }

    private void startRealGameLaunch() {
        isActionInProgress = true;

        launchGroup.setOpacity(1.0);
        launchTitleText.setText(LanguageManager.get("launch_progress"));
        launchTitleText.setVisible(true);
        launchStatsFlow.setVisible(true);

        btnStartGame.setDisable(true);
        btnUpdate.setDisable(true);

        File gameExe = InstallManager.getGameExecutable();
        double exeSizeBytes = gameExe.exists() ? gameExe.length() : 0;
        double exeSizeMb = exeSizeBytes / (1024.0 * 1024.0);
        if (exeSizeMb <= 0) exeSizeMb = 25.0;

        final double totalMb = exeSizeMb;

        launchProgressBar.setProgress(0.0);
        String initialBracket = String.format("[0.0Mb of %.1f MB]", totalMb);
        updateStatsFlowText(launchStatsFlow, "0.0%", initialBracket);

        Task<Boolean> launchTask = new Task<>() {
            @Override
            protected Boolean call() throws Exception {
                InstallManager.closeGameIfRunning();

                for (int i = 1; i <= 5; i++) {
                    Thread.sleep(120);
                    double currentProgress = (i * 0.2);
                    double currentMb = totalMb * currentProgress;

                    String percentStr = String.format("%.1f%%", currentProgress * 100);
                    String bracketStr = String.format("[%.1fMb of %.1f MB]", currentMb, totalMb);

                    javafx.application.Platform.runLater(() -> {
                        launchProgressBar.setProgress(currentProgress);
                        updateStatsFlowText(launchStatsFlow, percentStr, bracketStr);
                    });
                }

                if (gameExe.exists()) {
                    ProcessBuilder pb = new ProcessBuilder(gameExe.getAbsolutePath());
                    pb.directory(gameExe.getParentFile());
                    Process p = pb.start();
                    Thread.sleep(500);
                    return p.isAlive();
                }
                return false;
            }
        };

        launchTask.setOnSucceeded(e -> {
            boolean isRunning = launchTask.getValue();
            if (isRunning) {
                launchProgressBar.setProgress(1.0);
                String fullBracket = String.format("[%.1fMb of %.1f MB]", totalMb, totalMb);
                updateStatsFlowText(launchStatsFlow, "100.0%", fullBracket);

                PauseTransition pause = new PauseTransition(Duration.seconds(0.4));
                pause.setOnFinished(ev -> {
                    Stage stage = (Stage) btnStartGame.getScene().getWindow();
                    if (stage != null) {
                        stage.setIconified(true);
                    }
                    isActionInProgress = false;
                    btnStartGame.setDisable(false);
                    updateButtonStates();
                });
                pause.play();
            } else {
                isActionInProgress = false;
                btnStartGame.setDisable(false);
                updateButtonStates();
            }
        });

        launchTask.setOnFailed(e -> {
            isActionInProgress = false;
            btnStartGame.setDisable(false);
            updateButtonStates();
        });

        Thread t = new Thread(launchTask);
        t.setDaemon(true);
        t.start();
    }

    private void startUpdateSearchProcess() {
        isActionInProgress = true;
        openSearchUpdateOverlay();

        Task<InstallManager.ReleaseInfo> checkUpdateTask = new Task<>() {
            @Override
            protected InstallManager.ReleaseInfo call() throws Exception {
                return InstallManager.fetchLatestRelease(REPO_OWNER, REPO_NAME);
            }
        };

        checkUpdateTask.setOnSucceeded(e -> {
            InstallManager.ReleaseInfo latestRelease = checkUpdateTask.getValue();
            String localVersion = InstallManager.getLocalVersion();

            boolean hasUpdate = !latestRelease.tagName.equalsIgnoreCase(localVersion);

            if (!hasUpdate) {
                searchContentBox.getChildren().clear();
                TextFlow upToDateFlow = LanguageManager.parseFormattedText("up_to_date_msg");
                upToDateFlow.setPrefWidth(380);
                upToDateFlow.getStyleClass().add("warning-text-container");
                upToDateFlow.setScaleX(1.4);
                upToDateFlow.setScaleY(1.5);
                upToDateFlow.setTranslateY(20);
                searchContentBox.getChildren().add(upToDateFlow);

                PauseTransition pause = new PauseTransition(Duration.seconds(1.8));
                pause.setOnFinished(ev -> {
                    closeSearchUpdateOverlay();
                    isActionInProgress = false;
                    updateButtonStates();
                });
                pause.play();

            } else {
                closeSearchUpdateOverlay();
                startUpdateDownloadProcess(latestRelease.downloadUrl, latestRelease.tagName);
            }
        });

        checkUpdateTask.setOnFailed(e -> {
            closeSearchUpdateOverlay();
            isActionInProgress = false;
            updateButtonStates();
            System.out.println("Error searching latest version on Github repo");
        });

        Thread t = new Thread(checkUpdateTask);
        t.setDaemon(true);
        t.start();
    }

    private void startUpdateDownloadProcess(String downloadUrl, String newVersion) {
        updateGroup.setOpacity(1.0);
        updateTitleText.setVisible(true);
        updateStatsFlow.setVisible(true);

        btnStartGame.setDisable(true);
        btnUpdate.setDisable(true);

        InstallManager.downloadAndInstall(downloadUrl, newVersion, new InstallManager.InstallCallback() {
            @Override
            public void onProgress(double progress, double downloadedMb, double totalMb) {
                if (progress >= 0) {
                    updateProgressBar.setProgress(progress);
                    String percentStr = String.format("%.1f%%", progress * 100);
                    String bracketStr = String.format("[%.1fMb of %.1f MB]", downloadedMb, totalMb);
                    updateStatsFlowText(updateStatsFlow, percentStr, bracketStr);
                }
            }

            @Override
            public void onCompleted() {
                isActionInProgress = false;
                btnStartGame.setDisable(false);
                btnUpdate.setDisable(false);
                updateButtonStates();
            }

            @Override
            public void onError(String message) {
                isActionInProgress = false;
                btnStartGame.setDisable(false);
                btnUpdate.setDisable(false);
                updateButtonStates();
            }
        });
    }

    private void startInstallationProcess() {
        isActionInProgress = true;

        launchGroup.setOpacity(1.0);
        launchTitleText.setVisible(true);
        launchStatsFlow.setVisible(true);
        btnStartGame.setDisable(true);

        Task<InstallManager.ReleaseInfo> fetchTask = new Task<>() {
            @Override
            protected InstallManager.ReleaseInfo call() throws Exception {
                return InstallManager.fetchLatestRelease(REPO_OWNER, REPO_NAME);
            }
        };

        fetchTask.setOnSucceeded(e -> {
            InstallManager.ReleaseInfo release = fetchTask.getValue();
            InstallManager.downloadAndInstall(release.downloadUrl, release.tagName, new InstallManager.InstallCallback() {
                @Override
                public void onProgress(double progress, double downloadedMb, double totalMb) {
                    if (progress >= 0) {
                        launchProgressBar.setProgress(progress);
                        String percentStr = String.format("%.1f%%", progress * 100);
                        String bracketStr = String.format("[%.1fMb of %.1f MB]", downloadedMb, totalMb);
                        updateStatsFlowText(launchStatsFlow, percentStr, bracketStr);
                    }
                }

                @Override
                public void onCompleted() {
                    isActionInProgress = false;
                    checkGameInstallation();
                    btnStartGame.setDisable(false);
                    updateButtonStates();
                }

                @Override
                public void onError(String message) {
                    isActionInProgress = false;
                    btnStartGame.setDisable(false);
                    updateButtonStates();
                }
            });
        });

        fetchTask.setOnFailed(e -> {
            isActionInProgress = false;
            btnStartGame.setDisable(false);
            updateButtonStates();
        });

        Thread t = new Thread(fetchTask);
        t.setDaemon(true);
        t.start();
    }

    private Button createCustomBoxButton(String text, String styleClass, String hexColor) {
        Button btn = new Button();
        btn.getStyleClass().add(styleClass);

        btn.setMinSize(180, 48);
        btn.setPrefSize(180, 48);
        btn.setMaxSize(180, 48);

        Text labelText = new Text(text);
        labelText.setFill(Color.WHITE);
        
        if (pressStartFontText != null) {
            labelText.setFont(Font.font(pressStartFontText.getFamily(), 10));
        } else {
            labelText.setFont(Font.font("Press Start 2P", 10));
        }

        double maxTextWidth = 130.0; 
        
        labelText.boundsInLocalProperty().addListener((obs, oldBounds, newBounds) -> {
            double currentWidth = newBounds.getWidth();
            if (currentWidth > maxTextWidth) {
                double scaleFactor = maxTextWidth / currentWidth;
                labelText.setScaleX(scaleFactor);
                labelText.setScaleY(scaleFactor);
            } else {
                labelText.setScaleX(1.0);
                labelText.setScaleY(1.0);
            }
        });

        btn.setGraphic(labelText);

        return btn;
    }

    private void loadGameplayImages() {
        File folder = new File("media/gameplays");
        if (folder.exists() && folder.isDirectory()) {
            File[] files = folder.listFiles((dir, name) -> 
                name.toLowerCase().endsWith(".png") || name.toLowerCase().endsWith(".jpg") || name.toLowerCase().endsWith(".jpeg")
            );
            if (files != null) {
                for (File file : files) {
                    gameplayImages.add(new Image(file.toURI().toString()));
                }
            }
        }
    }

    private Button createIconButtonWithImage(String imagePath, String styleClass, double size) {
        Button btn = new Button();
        btn.getStyleClass().add(styleClass);

        File file = new File(imagePath);
        if (file.exists()) {
            Image img = new Image(file.toURI().toString());
            ImageView imgView = new ImageView(img);
            
            imgView.setFitWidth(size);
            imgView.setFitHeight(size);
            imgView.setPreserveRatio(true);
            
            Glow glowEffect = new Glow(0.5);
            
            btn.setOnMouseEntered(e -> imgView.setEffect(glowEffect));
            btn.setOnMouseExited(e -> imgView.setEffect(null));
            
            btn.setGraphic(imgView);
        }

        return btn;
    }

    public static void main(String[] args) {
        launch(args);
    }
}