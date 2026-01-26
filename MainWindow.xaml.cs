using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using Wpf.Ui;
using Wpf.Ui.Controls;
using Wpf.Ui.Appearance;
using Wpf.Ui.Abstractions;

namespace SSF2EventCompilerWPF
{
    public partial class MainWindow : Window
    {
        private string exeDir;
        private List<EventData> events = new List<EventData>();
        private CancellationTokenSource? cts;
        private Card? currentlyHighlightedCard;
        private List<CustomTheme> customThemes = new List<CustomTheme>();

        public class EventData
        {
        public string Name { get; set; } = "";
        public string Description { get; set; } = "";
        public string File { get; set; } = "";
        public string Id { get; set; } = "";
        public string Creator { get; set; } = "";
    }

    public class GitHubItem
    {
        public string? name { get; set; }
        public string? type { get; set; }
        public long size { get; set; }
        public string? download_url { get; set; }
    }

    public MainWindow()
    {
        InitializeComponent();

        exeDir = AppDomain.CurrentDomain.BaseDirectory;

        LoadEvents();
        LoadSavedSelections();
        LoadCustomThemes();
        UpdateStatus("Ready");
        LogMessage("SSF2 Event Compiler ready.");
        LogMessage("Click 'Compile' to start compilation.");
        Console.WriteLine("MainWindow GUI initialization complete");

        // Set up event handlers for icon
        this.Loaded += MainWindow_Loaded;
    }

    private void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        // Set title bar icon
        var iconPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "aflex_lite", "icon.ico");
        if (File.Exists(iconPath))
        {
            try
            {
                using (var icon = new System.Drawing.Icon(iconPath))
                {
                    var bitmapSource = System.Windows.Interop.Imaging.CreateBitmapSourceFromHIcon(
                        icon.Handle,
                        System.Windows.Int32Rect.Empty,
                        System.Windows.Media.Imaging.BitmapSizeOptions.FromWidthAndHeight(16, 16));

                    TitleBarIcon.Source = bitmapSource;
                    Console.WriteLine($"Title bar icon set: {iconPath}");
                    
                    // Set taskbar icon (doubled size)
                    var taskbarIcon = new System.Windows.Media.Imaging.BitmapImage();
                    taskbarIcon.BeginInit();
                    taskbarIcon.UriSource = new Uri(iconPath);
                    taskbarIcon.DecodePixelWidth = 48;  // Double the typical 16x16 size
                    taskbarIcon.DecodePixelHeight = 48;
                    taskbarIcon.EndInit();
                    this.Icon = taskbarIcon;
                    Console.WriteLine($"Taskbar icon set (48x48): {iconPath}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to set icons: {ex.Message}");
            }
        }
        else
        {
            Console.WriteLine($"Icon file not found: {iconPath}");
        }

        // Load saved theme after window is fully loaded
        LoadSavedTheme();
    }

    private void ThemeSelector_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        // This method is now handled in SettingsWindow
    }

    private void SettingsButton_Click(object sender, RoutedEventArgs e)
    {
        var settingsWindow = new SettingsWindow(this);
        settingsWindow.Owner = this;

        // Apply current theme to the settings window
        var currentTheme = GetCurrentTheme();
        if (!string.IsNullOrEmpty(currentTheme))
        {
            var customTheme = customThemes.FirstOrDefault(t => t.Name == currentTheme);
            if (customTheme != null)
            {
                ApplyCustomThemeToWindow(settingsWindow, customTheme);
            }
        }

        settingsWindow.ShowDialog();
    }

    private string GetCurrentTheme()
    {
        try
        {
            var themeFile = Path.Combine(exeDir, "aflex_lite", "current_theme.txt");
            if (File.Exists(themeFile))
            {
                return File.ReadAllText(themeFile).Trim();
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error getting current theme: {ex.Message}");
        }
        return "Light"; // Default theme
    }

    private void ApplyCustomThemeToWindow(Window window, CustomTheme theme)
    {
        try
        {
            // Apply background color
            if (!string.IsNullOrEmpty(theme.BackgroundColor))
            {
                string bgColorString = theme.BackgroundColor;
                if (!bgColorString.StartsWith("#"))
                {
                    bgColorString = "#" + bgColorString;
                }
                var bgColor = (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString(bgColorString);
                var bgBrush = new System.Windows.Media.SolidColorBrush(bgColor);
                window.Background = bgBrush;
                window.Resources["SolidBackgroundFillColorBaseBrush"] = bgBrush;
                window.Resources["ApplicationBackgroundBrush"] = bgBrush;
            }

            // Apply text color by updating theme resources
            if (!string.IsNullOrEmpty(theme.TextColor))
            {
                string textColorString = theme.TextColor;
                if (!textColorString.StartsWith("#"))
                {
                    textColorString = "#" + textColorString;
                }
                var textColor = (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString(textColorString);
                var textBrush = new System.Windows.Media.SolidColorBrush(textColor);

                // Update WPF-UI text color resources in the window's resources
                window.Resources["TextFillColorPrimaryBrush"] = textBrush;
                window.Resources["TextFillColorSecondaryBrush"] = textBrush;
                window.Resources["TextFillColorTertiaryBrush"] = textBrush;
                window.Resources["TextFillColorDisabledBrush"] = textBrush;

                // Also set window foreground as fallback
                window.Foreground = textBrush;
            }

            // Apply font family
            // Removed to prevent icon issues

            // Apply font size
            // Removed to prevent icon issues

            // Apply accent color to buttons in this window
            if (!string.IsNullOrEmpty(theme.AccentColor))
            {
                string accentColorString = theme.AccentColor;
                if (!accentColorString.StartsWith("#"))
                {
                    accentColorString = "#" + accentColorString;
                }
                var accentColor = (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString(accentColorString);
                var accentBrush = new SolidColorBrush(accentColor);

                // Set button backgrounds
                if (window.FindName("CreateThemeButton") is Wpf.Ui.Controls.Button createButton)
                {
                    createButton.Background = accentBrush;
                }
                if (window.FindName("SaveButton") is Wpf.Ui.Controls.Button saveButton)
                {
                    saveButton.Background = accentBrush;
                }
                if (window.FindName("CancelButton") is Wpf.Ui.Controls.Button cancelButton)
                {
                    cancelButton.Background = accentBrush;
                }
                if (window.FindName("ExportThemeButton") is Wpf.Ui.Controls.Button exportButton)
                {
                    exportButton.Background = accentBrush;
                }
                if (window.FindName("ImportThemeButton") is Wpf.Ui.Controls.Button importButton)
                {
                    importButton.Background = accentBrush;
                }
                // For dynamic buttons, they will be updated when recreated
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error applying custom theme to window: {ex.Message}");
        }
    }

    public void SaveCurrentTheme(string theme)
    {
        // Save theme to a simple text file for persistence
        try
        {
            var themeFile = Path.Combine(exeDir, "aflex_lite", "current_theme.txt");
            File.WriteAllText(themeFile, theme);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error saving theme: {ex.Message}");
        }
    }

    private void LoadSavedTheme()
    {
        try
        {
            var themeFile = Path.Combine(exeDir, "aflex_lite", "current_theme.txt");
            if (File.Exists(themeFile))
            {
                var savedTheme = File.ReadAllText(themeFile).Trim();
                if (!string.IsNullOrEmpty(savedTheme))
                {
                    ApplyTheme(savedTheme);
                    LogMessage($"Loaded saved theme: {savedTheme}");
                    return;
                }
            }
            // Default to Dark theme on first launch
            ApplyTheme("Dark");
            LogMessage("Applied built-in theme defaults for: Dark");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error loading saved theme: {ex.Message}");
            // Fallback to Dark theme
            ApplyTheme("Dark");
            LogMessage("Applied built-in theme defaults for: Dark");
        }
    }

    public void ApplyTheme(string themeName)
    {
        try
        {
            // Check if it's a custom theme first
            var customTheme = customThemes.FirstOrDefault(t => t.Name == themeName);
            if (customTheme != null)
            {
                ApplyCustomTheme(customTheme);
                LogMessage($"Theme switched to: {themeName}");
                SaveCurrentTheme(themeName);
                return;
            }

            // Default accent color
            var accentColor = System.Windows.Media.Color.FromRgb(0, 120, 212); // Default blue

            switch (themeName)
            {
                case "Light":
                    ApplicationThemeManager.Apply(ApplicationTheme.Light);
                    ApplyBuiltInThemeDefaults("Light");
                    break;
                case "Dark":
                    ApplicationThemeManager.Apply(ApplicationTheme.Dark);
                    ApplyBuiltInThemeDefaults("Dark");
                    break;
                case "HighContrast":
                    // No WPF-UI theme applied, just custom colors
                    accentColor = System.Windows.Media.Color.FromRgb(255, 255, 255); // White for high contrast
                    ApplyBuiltInThemeDefaults("HighContrast");
                    break;
                case "Gamer":
                    // Custom gamer theme - dark with neon green accent colors
                    ApplicationThemeManager.Apply(ApplicationTheme.Dark);
                    accentColor = System.Windows.Media.Color.FromRgb(57, 255, 20); // Neon green
                    ApplicationAccentColorManager.Apply(accentColor);
                    ApplyBuiltInThemeDefaults("Gamer");
                    break;
                case "BlueOcean":
                    // Blue ocean theme - light blue background
                    ApplicationThemeManager.Apply(ApplicationTheme.Light);
                    accentColor = System.Windows.Media.Color.FromRgb(0, 122, 204); // Ocean blue
                    ApplicationAccentColorManager.Apply(accentColor);
                    ApplyBuiltInThemeDefaults("BlueOcean");
                    break;
                case "Sunset":
                    // Sunset theme - warm colors
                    ApplicationThemeManager.Apply(ApplicationTheme.Dark);
                    accentColor = System.Windows.Media.Color.FromRgb(255, 107, 107); // Coral
                    ApplicationAccentColorManager.Apply(accentColor);
                    ApplyBuiltInThemeDefaults("Sunset");
                    break;
                default:
                    ApplicationThemeManager.Apply(ApplicationTheme.Light);
                    ApplyBuiltInThemeDefaults("Light");
                    break;
            }

            // Set button backgrounds to the accent color
            var accentBrush = new SolidColorBrush(accentColor);
            if (syncButton != null) syncButton.Background = accentBrush;
            if (compileButton != null) compileButton.Background = accentBrush;
            if (compileLegacyButton != null) compileLegacyButton.Background = accentBrush;

            LogMessage($"Theme switched to: {themeName}");
            SaveCurrentTheme(themeName); // Save the theme for persistence
        }
        catch (Exception ex)
        {
            LogMessage($"Error applying theme {themeName}: {ex.Message}");
        }
    }

    public void ApplyCustomTheme(CustomTheme theme)
    {
        try
        {
            // Apply base theme (always dark for custom themes)
            ApplicationThemeManager.Apply(ApplicationTheme.Dark);

            // Apply accent color
            try
            {
                string accentColorString = theme.AccentColor;
                if (!accentColorString.StartsWith("#"))
                {
                    accentColorString = "#" + accentColorString;
                }
                var accentColor = (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString(accentColorString);
                ApplicationAccentColorManager.Apply(accentColor);
                Console.WriteLine($"Applied accent color: {accentColorString}");

                // Set button backgrounds to accent color for immediate visual feedback
                var accentBrush = new SolidColorBrush(accentColor);
                if (syncButton != null) syncButton.Background = accentBrush;
                if (compileButton != null) compileButton.Background = accentBrush;
                if (compileLegacyButton != null) compileLegacyButton.Background = accentBrush;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to apply accent color {theme.AccentColor}: {ex.Message}");
                // Use default accent color if parsing fails
                ApplicationAccentColorManager.Apply(System.Windows.Media.Color.FromRgb(0, 120, 212)); // Default blue accent
            }

            // Apply custom colors to the application
            try
            {
                System.Windows.Media.Color bgColor = default;
                bool hasBgColor = false;

                if (!string.IsNullOrEmpty(theme.BackgroundColor))
                {
                    string bgColorString = theme.BackgroundColor;
                    if (!bgColorString.StartsWith("#"))
                    {
                        bgColorString = "#" + bgColorString;
                    }
                    bgColor = (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString(bgColorString);
                    hasBgColor = true;
                    // Apply background color to the main window
                    this.Background = new System.Windows.Media.SolidColorBrush(bgColor);

                    // Also apply to any open SettingsWindow
                    foreach (var window in Application.Current.Windows)
                    {
                        if (window is SettingsWindow settingsWindow)
                        {
                            settingsWindow.Background = new System.Windows.Media.SolidColorBrush(bgColor);
                        }
                    }

                    Console.WriteLine($"Background color set to: {bgColorString}");
                }

                if (!string.IsNullOrEmpty(theme.TextColor))
                {
                    string textColorString = theme.TextColor;
                    if (!textColorString.StartsWith("#"))
                    {
                        textColorString = "#" + textColorString;
                    }
                    var textColor = (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString(textColorString);
                    var textBrush = new System.Windows.Media.SolidColorBrush(textColor);

                    // Update WPF-UI text color resources in the main window
                    this.Resources["TextFillColorPrimaryBrush"] = textBrush;
                    this.Resources["TextFillColorSecondaryBrush"] = textBrush;
                    this.Resources["TextFillColorTertiaryBrush"] = textBrush;
                    this.Resources["TextFillColorDisabledBrush"] = textBrush;

                    // Update dynamic CheckBoxes in event list
                    if (eventStackPanel != null)
                    {
                        foreach (var child in eventStackPanel.Children)
                        {
                            if (child is Card card && card.Content is CheckBox checkBox)
                            {
                                checkBox.Foreground = textBrush;
                            }
                        }
                    }

                    // Update TextBox elements
                    if (descriptionTextBox != null)
                    {
                        descriptionTextBox.Foreground = textBrush;
                    }
                    if (logTextBox != null)
                    {
                        logTextBox.Foreground = textBrush;
                    }

                    // Also apply to any open SettingsWindow
                    foreach (var window in Application.Current.Windows)
                    {
                        if (window is SettingsWindow settingsWindow)
                        {
                            settingsWindow.Resources["TextFillColorPrimaryBrush"] = textBrush;
                            settingsWindow.Resources["TextFillColorSecondaryBrush"] = textBrush;
                            settingsWindow.Resources["TextFillColorTertiaryBrush"] = textBrush;
                            settingsWindow.Resources["TextFillColorDisabledBrush"] = textBrush;

                            // Update any dynamic elements in settings window if needed
                        }
                    }

                    Console.WriteLine($"Text color set to: {textColorString}");
                }

                // Update background resource for title bar and WPF-UI elements
                if (hasBgColor)
                {
                    var bgBrush = new System.Windows.Media.SolidColorBrush(bgColor);
                    this.Resources["SolidBackgroundFillColorBaseBrush"] = bgBrush;
                    this.Resources["ApplicationBackgroundBrush"] = bgBrush;

                    foreach (var window in Application.Current.Windows)
                    {
                        if (window is SettingsWindow settingsWindow)
                        {
                            settingsWindow.Resources["SolidBackgroundFillColorBaseBrush"] = bgBrush;
                            settingsWindow.Resources["ApplicationBackgroundBrush"] = bgBrush;
                        }
                        if (window is ThemeCreatorWindow themeWindow)
                        {
                            themeWindow.Resources["SolidBackgroundFillColorBaseBrush"] = bgBrush;
                            themeWindow.Resources["ApplicationBackgroundBrush"] = bgBrush;
                        }
                    }
                }

                // Fonts remain default to prevent icon issues
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to apply custom colors: {ex.Message}");
            }

            // Note: Font customization would require more complex implementation
            // For now, we focus on base theme and accent color
        }
        catch (Exception ex)
        {
            LogMessage($"Error applying custom theme {theme.Name}: {ex.Message}");
        }
    }



    private void ApplyBuiltInThemeDefaults(string themeName)
    {
        System.Windows.Media.Color textColor;
        System.Windows.Media.Color bgColor;

        switch (themeName)
        {
            case "Light":
                textColor = System.Windows.Media.Colors.Black;
                bgColor = System.Windows.Media.Color.FromRgb(249, 249, 249); // Light gray
                break;
            case "Dark":
                textColor = System.Windows.Media.Colors.White;
                bgColor = System.Windows.Media.Color.FromRgb(28, 28, 28); // Dark
                break;
            case "HighContrast":
                textColor = System.Windows.Media.Colors.White;
                bgColor = System.Windows.Media.Colors.Black;
                break;
            case "Gamer":
                textColor = System.Windows.Media.Color.FromRgb(57, 255, 20); // Neon green
                bgColor = System.Windows.Media.Color.FromRgb(10, 10, 10); // Very dark
                break;
            case "BlueOcean":
                textColor = System.Windows.Media.Color.FromRgb(30, 30, 50); // Dark blue-gray
                bgColor = System.Windows.Media.Color.FromRgb(173, 216, 230); // Light blue
                break;
            case "Sunset":
                textColor = System.Windows.Media.Color.FromRgb(255, 255, 255); // White
                bgColor = System.Windows.Media.Color.FromRgb(45, 45, 45); // Dark gray
                break;
            default:
                textColor = System.Windows.Media.Colors.Black;
                bgColor = System.Windows.Media.Color.FromRgb(249, 249, 249);
                break;
        }

        var textBrush = new System.Windows.Media.SolidColorBrush(textColor);
        var bgBrush = new System.Windows.Media.SolidColorBrush(bgColor);

        // Update resources
        this.Resources["TextFillColorPrimaryBrush"] = textBrush;
        this.Resources["TextFillColorSecondaryBrush"] = textBrush;
        this.Resources["TextFillColorTertiaryBrush"] = textBrush;
        this.Resources["TextFillColorDisabledBrush"] = textBrush;
        this.Resources["SolidBackgroundFillColorBaseBrush"] = bgBrush;
        this.Resources["ApplicationBackgroundBrush"] = bgBrush;

        // Update background
        this.Background = bgBrush;

        // Fonts remain default to prevent icon issues

        // Update dynamic elements
        if (eventStackPanel != null)
        {
            foreach (var child in eventStackPanel.Children)
            {
                if (child is Card card && card.Content is CheckBox checkBox)
                {
                    checkBox.Foreground = textBrush;
                    // Fonts remain default
                }
            }
        }
        if (descriptionTextBox != null)
        {
            descriptionTextBox.Foreground = textBrush;
            // Fonts remain default
        }
        if (logTextBox != null)
        {
            logTextBox.Foreground = textBrush;
            // Fonts remain default
        }

        // Apply to open windows
        foreach (var window in Application.Current.Windows)
        {
            if (window is SettingsWindow settingsWindow)
            {
                settingsWindow.Resources["TextFillColorPrimaryBrush"] = textBrush;
                settingsWindow.Resources["TextFillColorSecondaryBrush"] = textBrush;
                settingsWindow.Resources["TextFillColorTertiaryBrush"] = textBrush;
                settingsWindow.Resources["TextFillColorDisabledBrush"] = textBrush;
                settingsWindow.Resources["SolidBackgroundFillColorBaseBrush"] = bgBrush;
                settingsWindow.Resources["ApplicationBackgroundBrush"] = bgBrush;
                settingsWindow.Background = bgBrush;
                // Fonts remain default
            }
            if (window is ThemeCreatorWindow themeWindow)
            {
                themeWindow.Resources["TextFillColorPrimaryBrush"] = textBrush;
                themeWindow.Resources["TextFillColorSecondaryBrush"] = textBrush;
                themeWindow.Resources["TextFillColorTertiaryBrush"] = textBrush;
                themeWindow.Resources["TextFillColorDisabledBrush"] = textBrush;
                themeWindow.Resources["SolidBackgroundFillColorBaseBrush"] = bgBrush;
                themeWindow.Resources["ApplicationBackgroundBrush"] = bgBrush;
                themeWindow.Background = bgBrush;
                // Fonts remain default
            }
        }

        Console.WriteLine($"Applied built-in theme defaults for: {themeName}");
    }

    public void LoadCustomThemes()
    {
        try
        {
            var themesFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "custom_themes.json");
            if (File.Exists(themesFile))
            {
                var json = File.ReadAllText(themesFile);
                customThemes = JsonSerializer.Deserialize<List<CustomTheme>>(json) ?? new List<CustomTheme>();
            }
        }
        catch (Exception ex)
        {
            LogMessage($"Error loading custom themes: {ex.Message}");
            customThemes = new List<CustomTheme>();
        }
    }

    public List<CustomTheme> GetCustomThemes()
    {
        return customThemes;
    }

    public void AddCustomTheme(CustomTheme theme)
    {
        // Remove existing theme with same name if it exists
        customThemes.RemoveAll(t => t.Name == theme.Name);
        customThemes.Add(theme);
    }

    public void DeleteCustomTheme(string themeName)
    {
        customThemes.RemoveAll(t => t.Name == themeName);
        SaveCustomThemes();
    }

    private void SaveCustomThemes()
    {
        try
        {
            var themesFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "custom_themes.json");
            var json = JsonSerializer.Serialize(customThemes, new JsonSerializerOptions { WriteIndented = true });
            File.WriteAllText(themesFile, json);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error saving custom themes: {ex.Message}");
        }
    }

    private void LogMessage(string message)
    {
        Console.WriteLine(message);
        // Log to UI console if available
        if (logTextBox != null)
        {
            Dispatcher.Invoke(() =>
            {
                logTextBox.AppendText(message + "\r\n");
                logTextBox.ScrollToEnd();
            });
        }
    }

    private void UpdateStatus(string status)
    {
        if (statusTextBlock != null)
        {
            Dispatcher.Invoke(() =>
            {
                statusTextBlock.Text = status;
            });
        }
    }

    private async void RunConsoleMode()
    {
        Console.WriteLine("SSF2 Event Compiler - Console Mode");
        Console.WriteLine("===================================");

        exeDir = AppDomain.CurrentDomain.BaseDirectory;
        Console.WriteLine($"Working directory: {exeDir}");

        // Load events
        LoadEvents();
        Console.WriteLine($"Loaded {events.Count} events");

        // Compile all events
        Console.WriteLine("Starting compilation...");
        var success = await StartCompilation(false, false, null); // showWarnings=false, useLegacy=false, selectedFiles=null (compile all)

        if (success)
        {
            Console.WriteLine("Compilation completed successfully!");
        }
        else
        {
            Console.WriteLine("Compilation failed!");
        }
    }

        private void LoadEvents()
        {
            Console.WriteLine("Starting LoadEvents...");
            events.Clear();
            // Only clear GUI elements if they exist (GUI mode)
            if (eventStackPanel != null)
            {
                eventStackPanel.Children.Clear();
                // Add MouseLeave handler to clear highlights when mouse leaves the entire selection area
                eventStackPanel.MouseLeave += (sender, e) =>
                {
                    // Don't clear bold when leaving the selection area - keep it for the currently previewed event
                };
            }
            var sourceDirs = new[] { "files", "aflex_lite/online", "aflex_lite/legacy", "aflex_lite/api" };
            foreach (var d in sourceDirs)
            {
                var dirPath = Path.Combine(exeDir, d);
                Console.WriteLine($"Checking directory: {dirPath}");
                if (Directory.Exists(dirPath))
                {
                    var files = Directory.GetFiles(dirPath, "*.as");
                    Console.WriteLine($"Found {files.Length} .as files in {d}");
                    foreach (var f in files)
                    {
                        if (Path.GetFileName(f).Equals("ExternalEvents.as", StringComparison.OrdinalIgnoreCase)) continue;
                        Console.WriteLine($"Processing file: {Path.GetFileName(f)}");
                        var fileContent = File.ReadAllText(f);
                        var match = Regex.Match(fileContent, @"eventinfo\s*:\s*Array\s*=\s*\[\s*\{([\s\S]*?)\}\s*\]");
                        if (match.Success)
                        {
                            var infoStr = match.Groups[1].Value;
                            var infoObj = infoStr.Trim('{', '}');
                            var eventInfo = ParseObjectString(infoObj);
                            if (eventInfo.ContainsKey("name") && eventInfo.ContainsKey("id"))
                            {
                                var eventData = new EventData
                                {
                                    Name = eventInfo["name"],
                                    Description = eventInfo["description"],
                                    File = Path.GetFileNameWithoutExtension(f),
                                    Id = eventInfo["id"],
                                    Creator = eventInfo.ContainsKey("creator") ? eventInfo["creator"] : ""
                                };
                                events.Add(eventData);
                                // Only add GUI elements if they exist (GUI mode)
                                if (eventStackPanel != null)
                                {
                                    // Create a Card with CheckBox inside for modern UI
                                    var card = new Card
                                    {
                                        Style = (Style)FindResource("EventCardStyle")
                                    };

                                    var checkBox = new CheckBox
                                    {
                                        Content = eventData.Name,
                                        Tag = eventData.File,
                                        FontSize = 14,
                                        VerticalAlignment = VerticalAlignment.Center,
                                        Foreground = (System.Windows.Media.Brush)this.FindResource("TextFillColorPrimaryBrush")
                                    };

                                    checkBox.Checked += (sender, e) => SaveSelections();
                                    checkBox.Unchecked += (sender, e) => SaveSelections();

                                    card.Content = checkBox;

                                    checkBox.MouseEnter += (sender, e) =>
                                    {
                                        Console.WriteLine($"MouseEnter on {eventData.Name}");

                                        // Clear previous highlight
                                        if (currentlyHighlightedCard != null)
                                        {
                                            Console.WriteLine("Clearing previous highlight");
                                            var prevCheckBox = currentlyHighlightedCard.Content as CheckBox;
                                            if (prevCheckBox != null)
                                            {
                                                prevCheckBox.FontWeight = FontWeights.Normal;
                                            }
                                        }

                                        // Highlight current card by making text bold
                                        Console.WriteLine("Making text bold");
                                        checkBox.FontWeight = FontWeights.Bold;
                                        currentlyHighlightedCard = card;

                                        // Update description with creator info
                                        if (descriptionTextBox != null)
                                        {
                                            var description = eventData.Description;
                                            if (!string.IsNullOrEmpty(eventData.Creator))
                                            {
                                                description += $"\n\nCreator: {eventData.Creator}";
                                            }
                                            descriptionTextBox.Text = description;
                                        }

                                        // Load image
                                        var extensions = new[] { ".png", ".jpg", ".jpeg", ".gif", ".bmp" };
                                        var imageDirs = new[] { "images", "aflex_lite/online" };
                                        bool imageLoaded = false;
                                        foreach (var ext in extensions)
                                        {
                                            foreach (var imgDir in imageDirs)
                                            {
                                                var imagePath = Path.Combine(exeDir, imgDir, $"{eventData.Id}{ext}");
                                                Console.WriteLine($"Checking image: {imagePath}");
                                                if (File.Exists(imagePath))
                                                {
                                                    if (previewImage != null)
                                                    {
                                                        var bitmap = new BitmapImage();
                                                        bitmap.BeginInit();
                                                        bitmap.UriSource = new Uri(imagePath);
                                                        bitmap.EndInit();
                                                        previewImage.Source = bitmap;
                                                    }
                                                    Console.WriteLine($"Loaded image: {imagePath}");
                                                    imageLoaded = true;
                                                    break;
                                                }
                                            }
                                            if (imageLoaded) break;
                                        }
                                        if (!imageLoaded && previewImage != null)
                                        {
                                            previewImage.Source = null;
                                        }
                                        Console.WriteLine(imageLoaded ? "Image loaded" : "No image found");
                                    };

                                    checkBox.MouseLeave += (sender, e) =>
                                    {
                                        Console.WriteLine($"MouseLeave on {eventData.Name}");
                                        // Don't clear bold on mouse leave - keep it for the currently previewed event
                                    };

                                    eventStackPanel.Children.Add(card);
                                    Console.WriteLine($"Added card for {eventData.Name}");
                                }
                            }
                            else
                            {
                                Console.WriteLine($"Missing required properties in {Path.GetFileName(f)}");
                            }
                        }
                        else
                        {
                            Console.WriteLine($"No eventinfo found in {Path.GetFileName(f)}");
                        }
                    }
                }
                else
                {
                    Console.WriteLine($"Directory does not exist: {dirPath}");
                }
            }
            Console.WriteLine($"LoadEvents completed. Total events loaded: {events.Count}, checkboxes: {eventStackPanel?.Children.Count ?? 0}");
        }

        private Dictionary<string, string> ParseObjectString(string objStr)
        {
            var props = new Dictionary<string, string>();
            var matches = Regex.Matches(objStr, "\"([^\"]+)\":\\s*([\\s\\S]*?)(?=,\\s*\"[^\"]+\":|$)");
            foreach (Match m in matches)
            {
                var key = m.Groups[1].Value;
                var value = m.Groups[2].Value.Trim();
                if (key != "classAPI")
                {
                    value = value.Trim('"');
                }
                props[key] = value;
            }
            return props;
        }

        private void LoadSavedSelections()
        {
            Console.WriteLine("Starting LoadSavedSelections");
            // Skip in console mode
            if (eventStackPanel == null) return;

            var selectedFile = Path.Combine(exeDir, "aflex_lite", "selected_events.txt");
            Console.WriteLine($"Checking for selected_events.txt at: {selectedFile}");
            if (File.Exists(selectedFile))
            {
                var saved = File.ReadAllLines(selectedFile).Select(s => s.Trim()).Where(s => !string.IsNullOrEmpty(s)).ToList();
                Console.WriteLine($"Loaded {saved.Count} saved selections: {string.Join(", ", saved)}");

                // Find checkboxes within cards
                var checkboxes = new List<CheckBox>();
                foreach (var child in eventStackPanel.Children)
                {
                    if (child is Card card && card.Content is CheckBox checkbox)
                    {
                        checkboxes.Add(checkbox);
                    }
                }

                Console.WriteLine($"Found {checkboxes.Count} checkboxes in stack panel");
                foreach (var cb in checkboxes)
                {
                    if (cb.Tag is string tag && saved.Contains(tag))
                    {
                        cb.IsChecked = true;
                        Console.WriteLine($"Checked checkbox for {tag}");
                    }
                }
            }
            else
            {
                Console.WriteLine("selected_events.txt not found, no saved selections");
            }
        }

        private void SaveSelections()
        {
            if (eventStackPanel == null) return;

            var selectedFiles = new List<string>();
            foreach (var child in eventStackPanel.Children)
            {
                if (child is Card card && card.Content is CheckBox checkbox && checkbox.IsChecked == true)
                {
                    if (checkbox.Tag is string tag)
                    {
                        selectedFiles.Add(tag);
                    }
                }
            }

            var selectedFile = Path.Combine(exeDir, "aflex_lite", "selected_events.txt");
            try
            {
                File.WriteAllLines(selectedFile, selectedFiles);
                Console.WriteLine($"Saved {selectedFiles.Count} selections to {selectedFile}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error saving selections: {ex.Message}");
            }
        }

        private async Task<int> SyncOnlineFiles()
        {
            Console.WriteLine("Starting SyncOnlineFiles");
            var apiUrl = "https://api.github.com/repos/masterwebx/SSF2-Event-Vault/contents/compile/online";
            var folders = new[] { "aflex_lite/online", "files" };
            foreach (var folder in folders)
            {
                var path = Path.Combine(exeDir, folder);
                if (!Directory.Exists(path)) Directory.CreateDirectory(path);
                Console.WriteLine($"Ensured directory exists: {path}");
            }

            var downloaded = 0;
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Add("User-Agent", "SSF2-Event-Vault-Sync");
                Console.WriteLine("HttpClient created, fetching from GitHub API");
                try
                {
                    var response = await client.GetStringAsync(apiUrl);
                    var items = JsonSerializer.Deserialize<List<GitHubItem>>(response);
                    Console.WriteLine($"Fetched {items?.Count ?? 0} items from GitHub");
                    if (items != null)
                    {
                        foreach (var it in items.Where(i => i.type == "file"))
                        {
                            var folder = "aflex_lite/online";
                            var outPath = Path.Combine(exeDir, folder, it.name ?? "");
                            bool shouldDownload = true;
                            if (File.Exists(outPath))
                            {
                                var existingSize = new FileInfo(outPath).Length;
                                if (existingSize == it.size) shouldDownload = false;
                                Console.WriteLine($"File {it.name} exists, size check: existing {existingSize} vs remote {it.size}, shouldDownload: {shouldDownload}");
                            }
                            else
                            {
                                Console.WriteLine($"File {it.name} does not exist, will download");
                            }
                            if (shouldDownload)
                            {
                                var content = await client.GetByteArrayAsync(it.download_url ?? "");
                                File.WriteAllBytes(outPath, content);
                                downloaded++;
                                var msg = $"Downloaded {it.name} to {folder}";
                                LogMessage(msg);
                            }
                            else
                            {
                                var skipMsg = $"Skipped {it.name} in {folder} (unchanged)";
                                LogMessage(skipMsg);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    var failMsg = $"Sync-OnlineFiles failed: {ex.Message}";
                    LogMessage(failMsg);
                    return 0;
                }
            }
            Console.WriteLine($"SyncOnlineFiles completed, downloaded {downloaded} files");
            return downloaded;
        }

        private async Task<bool> StartCompilation(bool showWarnings, bool useLegacy, string[]? selectedFiles = null)
        {
            Console.WriteLine($"Starting StartCompilation with showWarnings={showWarnings}, useLegacy={useLegacy}, selectedFiles count={selectedFiles?.Length ?? 0}");
            var logMessage = $"{DateTime.Now}: Starting compilation...";
            LogMessage(logMessage);

            if (!Directory.Exists("images")) Directory.CreateDirectory("images");
            Console.WriteLine("Ensured images directory exists");

            var sourceDirs = useLegacy ? new[] { "aflex_lite/legacy" } : new[] { "files", "aflex_lite/online" };

            List<string> asFiles;
            List<Dictionary<string, string>> allEventInfos;
            List<string> linkageNames;
            string tempImagesDir = "";

            if (useLegacy)
            {
                var externalEventsFile = Path.Combine(exeDir, "aflex_lite", "legacy", "ExternalEvents.as");
                if (!File.Exists(externalEventsFile))
                {
                    var template = @"package 
{
    public class ExternalEvents 
    {
        public static var eventList2:Array = [];
    }
}";
                    File.WriteAllText(externalEventsFile, template);
                }
                asFiles = new List<string> { externalEventsFile };
                allEventInfos = new List<Dictionary<string, string>>();
                linkageNames = new List<string>();
            }
            else
            {
                var allFound = sourceDirs.SelectMany(d => Directory.GetFiles(Path.Combine(exeDir, d), "*.as")).ToList();
            Console.WriteLine($"Found {allFound.Count} .as files in source dirs: {string.Join(", ", sourceDirs)}");

            // Clean up any existing img_*.as files from previous compilations
            foreach (var dir in sourceDirs)
            {
                var dirPath = Path.Combine(exeDir, dir);
                var cleanupMsg = $"Checking directory for cleanup: {dirPath}, exists: {Directory.Exists(dirPath)}";
                Console.WriteLine(cleanupMsg);
                LogMessage(cleanupMsg);
                if (Directory.Exists(dirPath))
                {
                    var imgFiles = Directory.GetFiles(dirPath, "img_*.as");
                    var foundMsg = $"Found {imgFiles.Length} img_*.as files to delete in {dir}";
                    Console.WriteLine(foundMsg);
                    LogMessage(foundMsg);
                    foreach (var imgFile in imgFiles)
                    {
                        try
                        {
                            File.Delete(imgFile);
                            var deleteMsg = $"Deleted existing img file: {Path.GetFileName(imgFile)}";
                            Console.WriteLine(deleteMsg);
                            LogMessage(deleteMsg);
                        }
                        catch (Exception ex)
                        {
                            var errorMsg = $"Failed to delete {Path.GetFileName(imgFile)}: {ex.Message}";
                            Console.WriteLine(errorMsg);
                            LogMessage(errorMsg);
                        }
                    }
                }
            }

            var externalEventsFile = allFound.FirstOrDefault(f => Path.GetFileName(f).Equals("ExternalEvents.as", StringComparison.OrdinalIgnoreCase));
            var eventSourceFiles = allFound.Where(f => !Path.GetFileName(f).Equals("ExternalEvents.as", StringComparison.OrdinalIgnoreCase) && !Path.GetFileName(f).StartsWith("img_", StringComparison.OrdinalIgnoreCase)).ToList();
            Console.WriteLine($"ExternalEvents file: {externalEventsFile ?? "not found"}");
            Console.WriteLine($"Event source files before filtering: {eventSourceFiles.Count}");

            if (selectedFiles != null && selectedFiles.Length > 0)
            {
                eventSourceFiles = eventSourceFiles.Where(f => selectedFiles.Contains(Path.GetFileNameWithoutExtension(f))).ToList();
                Console.WriteLine($"After filtering by selectedFiles, event source files: {eventSourceFiles.Count}");
            }

            if (externalEventsFile == null)
            {
                externalEventsFile = Path.Combine(exeDir, "files", "ExternalEvents.as");
                var template = @"package 
{
    public class ExternalEvents 
    {
        public static var eventList2:Array = [];
    }
}";
                File.WriteAllText(externalEventsFile, template);
            }

            asFiles = new List<string>();
            asFiles.AddRange(eventSourceFiles);
            if (externalEventsFile != null) asFiles.Add(externalEventsFile);

            if (asFiles.Count == 0)
            {
                var errorMsg = "No .as files found in source folders";
                LogMessage(errorMsg);
                return false;
            }

            allEventInfos = new List<Dictionary<string, string>>();
            var eventNumber = 1;
            var idToNumber = new Dictionary<string, int>();
            var eventMsg = $"Processing {eventSourceFiles.Count} event source files";
            Console.WriteLine(eventMsg);
            LogMessage(eventMsg);
            foreach (var f in eventSourceFiles)
            {
                var fileContent = File.ReadAllText(f);
                var match = Regex.Match(fileContent, @"eventinfo\s*:\s*Array\s*=\s*\[\s*\{([\s\S]*?)\}\s*\]");
                if (match.Success)
                {
                    var infoStr = match.Groups[1].Value;
                    var infoObj = infoStr.Trim('{', '}');
                    var eventInfo = ParseObjectString(infoObj);
                    if (eventInfo.ContainsKey("name") && eventInfo.ContainsKey("id"))
                    {
                        var originalId = eventInfo["id"];
                        var foundMsg = $"Found event: {eventInfo["name"]} with ID: {originalId}";
                        Console.WriteLine(foundMsg);
                        LogMessage(foundMsg);
                        eventInfo["name"] = $"{eventNumber}. {eventInfo["name"]}";
                        idToNumber[originalId] = eventNumber;
                        eventNumber++;
                        allEventInfos.Add(eventInfo);
                    }
                    else
                    {
                        var missingMsg = $"Event in {Path.GetFileName(f)} missing name or id";
                        Console.WriteLine(missingMsg);
                        LogMessage(missingMsg);
                    }
                }
                else
                {
                    var noMatchMsg = $"No eventinfo match in {Path.GetFileName(f)}";
                    Console.WriteLine(noMatchMsg);
                    LogMessage(noMatchMsg);
                }
            }
            var processedMsg = $"Processed {allEventInfos.Count} events, idToNumber has {idToNumber.Count} entries";
            Console.WriteLine(processedMsg);
            LogMessage(processedMsg);

            if (externalEventsFile != null && allEventInfos.Count > 0)
            {
                var content = File.ReadAllText(externalEventsFile);
                var eventStrs = allEventInfos.Select(ev =>
                {
                    var lines = new List<string>();
                    foreach (var key in ev.Keys)
                    {
                        var value = ev[key];
                        if (key == "classAPI") lines.Add($"\"classAPI\":{value}");
                        else lines.Add($"\"{key}\": \"{value}\"");
                    }
                    return "         {\n" + string.Join(",\n", lines) + "\n         }";
                });
                var eventBlock = string.Join(",\n", eventStrs);
                var pattern = @"(eventList2\s*=\s*\[)[^\]]*(\];)";
                if (Regex.IsMatch(content, pattern))
                {
                    content = Regex.Replace(content, pattern, $"${{1}}\n{eventBlock}\n         ${{2}}");
                }
                else
                {
                    content += $"\n    public static var eventList2:Array = [\n{eventBlock}\n    ];\n";
                }
                File.WriteAllText(externalEventsFile, content);
                var msg = $"Updated ExternalEvents.as with {allEventInfos.Count} events from source files";
                LogMessage(msg);
            }

            linkageNames = new List<string>();
            if (!useLegacy)
            {
                tempImagesDir = Path.Combine(exeDir, "temp_images");
                try
                {
                    if (Directory.Exists(tempImagesDir))
                    {
                        Directory.Delete(tempImagesDir, true);
                        Console.WriteLine($"Deleted existing temp_images directory: {tempImagesDir}");
                    }
                    Directory.CreateDirectory(tempImagesDir);
                    Console.WriteLine($"Created temp_images directory: {tempImagesDir}");
                }
                catch (Exception ex)
                {
                    LogMessage($"Error managing temp_images directory: {ex.Message}");
                    return false;
                }

                var imageDirs = new[] { "images", "aflex_lite/online", "files" };
                var imageDirMsg = $"Looking for images in: {string.Join(", ", imageDirs)}";
                Console.WriteLine(imageDirMsg);
                LogMessage(imageDirMsg);
                var originalImageFiles = imageDirs.SelectMany(d => Directory.GetFiles(Path.Combine(exeDir, d), "*.*", SearchOption.AllDirectories).Where(f => new[] { ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".svg" }.Contains(Path.GetExtension(f).ToLower()))).ToList();
                var foundImagesMsg = $"Found {originalImageFiles.Count} image files in {string.Join(", ", imageDirs)}: {string.Join(", ", originalImageFiles.Select(Path.GetFileName))}";
                Console.WriteLine(foundImagesMsg);
                LogMessage(foundImagesMsg);
                    var idKeysMsg = $"idToNumber keys: {string.Join(", ", idToNumber.Keys)}";
                    Console.WriteLine(idKeysMsg);
                    LogMessage(idKeysMsg);
                    if (originalImageFiles.Count > 0)
                    {
                        foreach (var img in originalImageFiles)
                        {
                            var baseName = Path.GetFileNameWithoutExtension(img);
                            var processingMsg = $"Processing image: {baseName}, checking if in idToNumber: {idToNumber.ContainsKey(baseName)}";
                            Console.WriteLine(processingMsg);
                            LogMessage(processingMsg);
                            if (idToNumber.ContainsKey(baseName))
                            {
                                var number = idToNumber[baseName];
                                var newName = $"{number}{Path.GetExtension(img)}";
                                var newPath = Path.Combine(tempImagesDir, newName);
                                try
                                {
                                    File.Copy(img, newPath, true); // Overwrite if exists
                                    var copiedMsg = $"Copied {Path.GetFileName(img)} to temp_images/{newName}";
                                    Console.WriteLine(copiedMsg);
                                    LogMessage(copiedMsg);
                                }
                                catch (Exception ex)
                                {
                                    var errorMsg = $"Error copying image {Path.GetFileName(img)}: {ex.Message}";
                                    Console.WriteLine(errorMsg);
                                    LogMessage(errorMsg);
                                }
                            }
                            else
                            {
                                var skipMsg = $"Skipping image {baseName} - not in idToNumber";
                                Console.WriteLine(skipMsg);
                                LogMessage(skipMsg);
                            }
                        }
                        var imageFiles = Directory.GetFiles(tempImagesDir, "*.*").Where(f => new[] { ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".svg" }.Contains(Path.GetExtension(f).ToLower())).ToList();
                        var tempImagesMsg = $"Found {imageFiles.Count} images in temp_images directory";
                        Console.WriteLine(tempImagesMsg);
                        LogMessage(tempImagesMsg);

                        foreach (var img in imageFiles)
                        {
                            var linkageName = $"img_{Path.GetFileNameWithoutExtension(img).Replace(" ", "_").Replace("-", "_")}";
                            linkageNames.Add(linkageName);
                            var linkageMsg = $"Creating linkage {linkageName} for image {Path.GetFileName(img)}";
                            Console.WriteLine(linkageMsg);
                            LogMessage(linkageMsg);

                            var bitmapPath = img;
                            var embedPath = $"../temp_images/{Path.GetFileName(img)}";
                            int width = 0, height = 0;
                            try
                            {
                                using (var bitmap = new Bitmap(bitmapPath))
                                {
                                    width = bitmap.Width;
                                    height = bitmap.Height;
                                }
                                Console.WriteLine($"Image dimensions: {width}x{height}");
                            }
                            catch (Exception ex)
                            {
                                Console.WriteLine($"Error reading image dimensions: {ex.Message}");
                            }

                            var classContent = $@"package {{
    import flash.display.BitmapData;
    
    [Embed(source=""{embedPath}"")]
    public dynamic class {linkageName} extends BitmapData {{
        public function {linkageName}(param1:int = {width}, param2:int = {height}) {{
            super(param1, param2);
        }}
    }}
}}";
                            var sourceDir = useLegacy ? "legacy" : "files";
                            var classPath = Path.Combine(exeDir, sourceDir, $"{linkageName}.as");
                            File.WriteAllText(classPath, classContent);
                        }
                    }
                }
            }

            var mainFile = asFiles.FirstOrDefault(f => Path.GetFileName(f).Equals("ExternalEvents.as", StringComparison.OrdinalIgnoreCase));
            if (mainFile == null && asFiles.Any()) mainFile = asFiles[0];
            if (mainFile == null && asFiles.Any()) mainFile = asFiles[0];
            if (mainFile != null)
            {
                var mainName = Path.GetFileName(mainFile);
                var mainDir = Path.GetDirectoryName(mainFile);
                if (mainDir != null)
                {
                    var mainFolder = Path.GetRelativePath(exeDir, mainDir).Replace("\\", "/");
                    var relativeMain = mainFolder + "/" + mainName;

                    var flexHome = Path.Combine(exeDir, "aflex_lite");
                    var mxmlc = Path.Combine(flexHome, "bin", "mxmlc.bat");
                    var warningsFlag = showWarnings ? "true" : "false";
                    var sourcePathArg = useLegacy ? "aflex_lite/legacy,aflex_lite/api" : "files,aflex_lite/online,aflex_lite/api";

                    var includeClasses = linkageNames.Any() ? $"-includes={string.Join(",", linkageNames)}" : "";

                    var psi = new ProcessStartInfo
                    {
                        FileName = mxmlc,
                        WorkingDirectory = exeDir,
                        RedirectStandardOutput = true,
                        RedirectStandardError = true,
                        UseShellExecute = false,
                        CreateNoWindow = true
                    };

                    // Build arguments as list to avoid parsing issues
                    psi.ArgumentList.Add($"-warnings={warningsFlag}");
                    psi.ArgumentList.Add("-strict=true");
                    psi.ArgumentList.Add($"-source-path={sourcePathArg}");
                    psi.ArgumentList.Add($"-library-path={Path.Combine(flexHome, "frameworks", "libs", "framework.swc").Replace("\\", "/")},{Path.Combine(flexHome, "frameworks", "libs", "player", "32.0", "playerglobal.swc").Replace("\\", "/")}");
                    if (!string.IsNullOrEmpty(includeClasses))
                    {
                        psi.ArgumentList.Add(includeClasses);
                    }
                    psi.ArgumentList.Add(relativeMain);
                    psi.ArgumentList.Add("-output=custom_events.swf");

                    var process = Process.Start(psi);
                    if (process != null)
                    {
                        var outputTask = process.StandardOutput.ReadToEndAsync();
                        var errorTask = process.StandardError.ReadToEndAsync();
                        await Task.Run(() => process.WaitForExit(), cts?.Token ?? CancellationToken.None);
                        if (cts?.IsCancellationRequested == true)
                        {
                            process.Kill();
                            return false;
                        }
                        var output = await outputTask;
                        var error = await errorTask;
                        LogMessage($"Compiling {mainName}...");
                        if (!string.IsNullOrEmpty(output)) LogMessage(output);
                        if (!string.IsNullOrEmpty(error)) LogMessage(error);

                        var exitCode = process.ExitCode;
                        var msg = $"Compilation complete. Exit code: {exitCode}";
                        LogMessage(msg);

                        if (exitCode != 0)
                        {
                            msg = $"Compilation failed with exit code {exitCode}. Check the error messages above.";
                            LogMessage(msg);
                            return false;
                        }
                    }
                }
            }

            // Clean up
            if (!useLegacy && Directory.Exists(tempImagesDir)) Directory.Delete(tempImagesDir, true);
            foreach (var name in linkageNames)
            {
                var sourceDir = useLegacy ? "legacy" : "files";
                var path = Path.Combine(exeDir, sourceDir, $"{name}.as");
                if (File.Exists(path)) File.Delete(path);
            }

            return true;
        }



private void SelectToggleSwitch_Checked(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Select Toggle switched ON");
            int count = 0;

            // Select all
            foreach (var child in eventStackPanel.Children)
            {
                if (child is Card card && card.Content is CheckBox checkbox)
                {
                    checkbox.IsChecked = true;
                    count++;
                }
            }
            UpdateStatus($"Selected all {count} events");
            Console.WriteLine($"Selected {count} checkboxes");
            SaveSelections();
        }

        private void SelectToggleSwitch_Unchecked(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Select Toggle switched OFF");
            int count = 0;

            // Deselect all
            foreach (var child in eventStackPanel.Children)
            {
                if (child is Card card && card.Content is CheckBox checkbox)
                {
                    checkbox.IsChecked = false;
                    count++;
                }
            }
            UpdateStatus($"Deselected all {count} events");
            Console.WriteLine($"Deselected {count} checkboxes");
            SaveSelections();
        }

        private async void CompileButton_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Compile button clicked");
            compileButton.IsEnabled = false;
            ProgressRing.Visibility = Visibility.Visible;

            cts = new CancellationTokenSource();

            try
            {
                // Get selected checkboxes from cards
                var selected = new List<string>();
                foreach (var child in eventStackPanel.Children)
                {
                    if (child is Card card && card.Content is CheckBox checkbox && checkbox.IsChecked == true)
                    {
                        if (checkbox.Tag is string tag)
                        {
                            selected.Add(tag);
                        }
                    }
                }

                Console.WriteLine($"Selected files: {string.Join(", ", selected)}");
                // Save selections to aflex_lite folder
                SaveSelections();

                UpdateStatus($"Compiling {selected.Count} events...");

                var result = await StartCompilation(false, false, selected.ToArray());
                if (result)
                {
                    UpdateStatus("Compilation completed successfully!");
                }
                else
                {
                    UpdateStatus("Compilation failed. Check console for details.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error during compilation: {ex.Message}");
                UpdateStatus($"Compilation error: {ex.Message}");
            }
            finally
            {
                compileButton.IsEnabled = true;
                ProgressRing.Visibility = Visibility.Collapsed;
                cts?.Dispose();
                cts = null;
            }
        }

        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Cancel button clicked");
            cts?.Cancel();
            UpdateStatus("Cancelling compilation...");
        }

        private async void SyncButton_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Sync button clicked");
            syncButton.IsEnabled = false;
            ProgressRing.Visibility = Visibility.Visible;

            try
            {
                System.Windows.MessageBox.Show("Syncing online events...", "Syncing", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Information);
                var synced = await SyncOnlineFiles();
                var msg = synced == 0 ? "No files added from online" : synced == 1 ? "1 file added from online" : $"{synced} files added from online";
                System.Windows.MessageBox.Show(msg, "Sync Complete", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Information);
                LoadEvents(); // Reload events after sync
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show(ex.Message, "Sync Failed", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
                Console.WriteLine($"Sync error: {ex.Message}");
            }
            finally
            {
                syncButton.IsEnabled = true;
                ProgressRing.Visibility = Visibility.Collapsed;
            }
        }

        private async void CompileLegacyButton_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Compile Legacy button clicked");
            compileLegacyButton.IsEnabled = false;
            ProgressRing.Visibility = Visibility.Visible;

            cts = new CancellationTokenSource();

            try
            {
                UpdateStatus("Compiling legacy events...");

                var result = await StartCompilation(false, true, null); // showWarnings=false, useLegacy=true, selectedFiles=null (compile all from legacy)
                if (result)
                {
                    UpdateStatus("Legacy compilation completed successfully!");
                }
                else
                {
                    UpdateStatus("Legacy compilation failed. Check console for details.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error during legacy compilation: {ex.Message}");
                UpdateStatus($"Legacy compilation error: {ex.Message}");
            }
            finally
            {
                compileLegacyButton.IsEnabled = true;
                ProgressRing.Visibility = Visibility.Collapsed;
                cts?.Dispose();
                cts = null;
            }
        }

        private void RunSSF2Button_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("Run SSF2 button clicked");
            try
            {
                var ssf2Path = Path.Combine(exeDir, "..", "SSF2.exe");
                Console.WriteLine($"Checking for SSF2.exe at: {ssf2Path}");
                if (File.Exists(ssf2Path))
                {
                    Process.Start(new ProcessStartInfo { FileName = ssf2Path, UseShellExecute = true });
                    UpdateStatus("SSF2.exe launched successfully");
                    Console.WriteLine("Started SSF2.exe");
                }
                else
                {
                    UpdateStatus("SSF2.exe not found");
                    Console.WriteLine("SSF2.exe not found");
                }
            }
            catch (Exception ex)
            {
                UpdateStatus($"Failed to start SSF2: {ex.Message}");
                Console.WriteLine($"Error starting SSF2: {ex.Message}");
            }
        }

        // Custom Title Bar Event Handlers
        private void TitleBar_MouseLeftButtonDown(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            if (e.ButtonState == System.Windows.Input.MouseButtonState.Pressed)
            {
                this.DragMove();
            }
        }

        private void MinimizeButton_Click(object sender, RoutedEventArgs e)
        {
            this.WindowState = WindowState.Minimized;
        }

        private void MaximizeButton_Click(object sender, RoutedEventArgs e)
        {
            if (this.WindowState == WindowState.Maximized)
            {
                this.WindowState = WindowState.Normal;
                // Update maximize button icon to show maximize
                var maximizeText = (System.Windows.Controls.TextBlock)((System.Windows.Controls.Button)sender).Content;
                maximizeText.Text = "\uE739"; // Maximize icon
            }
            else
            {
                this.WindowState = WindowState.Maximized;
                // Update maximize button icon to show restore
                var maximizeText = (System.Windows.Controls.TextBlock)((System.Windows.Controls.Button)sender).Content;
                maximizeText.Text = "\uE923"; // Restore icon
            }
        }

        private void CloseButton_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }
    }
}