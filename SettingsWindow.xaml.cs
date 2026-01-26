using System;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Diagnostics;
using System.Windows.Media;
using Wpf.Ui.Controls;
using Wpf.Ui;

namespace SSF2EventCompilerWPF
{
    public partial class SettingsWindow : FluentWindow
    {
        private MainWindow mainWindow;
        private string currentTheme = "Light";

        public SettingsWindow(MainWindow mainWindow)
        {
            InitializeComponent();
            this.mainWindow = mainWindow;
            LoadSettings();
        }

        private void LoadSettings()
        {
            // Load saved theme FIRST
            var settingsFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "aflex_lite", "settings.json");
            if (File.Exists(settingsFile))
            {
                try
                {
                    var settings = System.Text.Json.JsonSerializer.Deserialize<SettingsData>(File.ReadAllText(settingsFile));
                    if (settings != null)
                    {
                        currentTheme = settings.Theme ?? "Light";
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error loading settings: {ex.Message}");
                }
            }

            // Then load all themes into the unified panel
            LoadAllThemesIntoPanel();
        }

        private System.Windows.Media.Color GetAccentColor(string themeTag)
        {
            var customTheme = mainWindow.GetCustomThemes().FirstOrDefault(t => t.Name == themeTag);
            if (customTheme != null && !string.IsNullOrEmpty(customTheme.AccentColor))
            {
                string accentString = customTheme.AccentColor;
                if (!accentString.StartsWith("#")) accentString = "#" + accentString;
                return (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString(accentString);
            }
            else
            {
                switch (themeTag)
                {
                    case "HighContrast":
                        return System.Windows.Media.Colors.White;
                    case "Gamer":
                        return System.Windows.Media.Color.FromRgb(57, 255, 20);
                    case "BlueOcean":
                        return System.Windows.Media.Color.FromRgb(0, 122, 204);
                    case "Sunset":
                        return System.Windows.Media.Color.FromRgb(255, 107, 107);
                    default:
                        return System.Windows.Media.Color.FromRgb(0, 120, 212);
                }
            }
        }

        private void LoadAllThemesIntoPanel()
        {
            ThemesPanel.Children.Clear();

            // Add built-in themes first
            var builtInThemes = new[]
            {
                new { Name = "Light Theme", Tag = "Light", IsBuiltIn = true },
                new { Name = "Dark Theme", Tag = "Dark", IsBuiltIn = true },
                new { Name = "High Contrast", Tag = "HighContrast", IsBuiltIn = true },
                new { Name = "Gamer Theme", Tag = "Gamer", IsBuiltIn = true },
                new { Name = "Blue Ocean", Tag = "BlueOcean", IsBuiltIn = true },
                new { Name = "Sunset", Tag = "Sunset", IsBuiltIn = true }
            };

            foreach (var theme in builtInThemes)
            {
                var themePanel = CreateThemePanel(theme.Name, theme.Tag, theme.IsBuiltIn, null);
                ThemesPanel.Children.Add(themePanel);
            }

            // Add custom themes
            var customThemes = mainWindow.GetCustomThemes();
            foreach (var theme in customThemes)
            {
                var themePanel = CreateThemePanel(theme.Name, theme.Name, false, theme);
                ThemesPanel.Children.Add(themePanel);
            }

            // Update button backgrounds based on current theme
            UpdateButtonBackgrounds(currentTheme);
        }

        private void UpdateButtonBackgrounds(string themeTag)
        {
            var accentColor = GetAccentColor(themeTag);
            var accentBrush = new SolidColorBrush(accentColor);

            CreateThemeButton.Background = accentBrush;
            SaveButton.Background = accentBrush;

            // Update Edit buttons in themes panel
            foreach (var child in ThemesPanel.Children)
            {
                if (child is Grid grid)
                {
                    foreach (var gridChild in grid.Children)
                    {
                        if (gridChild is Wpf.Ui.Controls.Button button && button.Content?.ToString() == "Edit")
                        {
                            button.Background = accentBrush;
                        }
                    }
                }
            }
        }

        private UIElement CreateThemePanel(string displayName, string themeTag, bool isBuiltIn, CustomTheme? customTheme)
        {
            var grid = new Grid();
            grid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
            grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
            grid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
            grid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
            grid.Margin = new Thickness(0, 0, 0, 8);

            // Radio button for selection
            var radioButton = new RadioButton
            {
                GroupName = "ThemeSelection",
                IsChecked = currentTheme == themeTag,
                VerticalAlignment = VerticalAlignment.Center,
                Margin = new Thickness(0, 0, 8, 0)
            };
            radioButton.Checked += (s, e) => ThemeRadioButton_Checked(s, e, themeTag);
            Grid.SetColumn(radioButton, 0);

            // Theme name and colors preview
            var themeInfo = new StackPanel { Orientation = Orientation.Horizontal, VerticalAlignment = VerticalAlignment.Center };
            Grid.SetColumn(themeInfo, 1);

            var themeName = new System.Windows.Controls.TextBlock
            {
                Text = displayName,
                FontSize = 14,
                FontWeight = FontWeights.Medium,
                Margin = new Thickness(0, 0, 12, 0)
            };
            themeName.SetResourceReference(System.Windows.Controls.TextBlock.ForegroundProperty, "TextFillColorPrimaryBrush");
            themeInfo.Children.Add(themeName);

            // Color previews (only for custom themes)
            if (!isBuiltIn && customTheme != null)
            {
                string accentColorString = customTheme.AccentColor;
                if (!accentColorString.StartsWith("#"))
                {
                    accentColorString = "#" + accentColorString;
                }
                var accentPreview = new Border
                {
                    Width = 16,
                    Height = 16,
                    Background = new System.Windows.Media.SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString(accentColorString)),
                    BorderBrush = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(100, 100, 100)),
                    BorderThickness = new Thickness(1),
                    CornerRadius = new CornerRadius(2),
                    Margin = new Thickness(0, 0, 4, 0)
                };
                themeInfo.Children.Add(accentPreview);

                string bgColorString = customTheme.BackgroundColor;
                if (!bgColorString.StartsWith("#"))
                {
                    bgColorString = "#" + bgColorString;
                }
                var bgPreview = new Border
                {
                    Width = 16,
                    Height = 16,
                    Background = new System.Windows.Media.SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString(bgColorString)),
                    BorderBrush = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(100, 100, 100)),
                    BorderThickness = new Thickness(1),
                    CornerRadius = new CornerRadius(2),
                    Margin = new Thickness(0, 0, 4, 0)
                };
                themeInfo.Children.Add(bgPreview);

                string textColorString = customTheme.TextColor;
                if (!textColorString.StartsWith("#"))
                {
                    textColorString = "#" + textColorString;
                }
                var textPreview = new Border
                {
                    Width = 16,
                    Height = 16,
                    Background = new System.Windows.Media.SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString(textColorString)),
                    BorderBrush = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(100, 100, 100)),
                    BorderThickness = new Thickness(1),
                    CornerRadius = new CornerRadius(2),
                    Margin = new Thickness(0, 0, 4, 0)
                };
                themeInfo.Children.Add(textPreview);
            }

            grid.Children.Add(radioButton);
            grid.Children.Add(themeInfo);

            // Edit and Delete buttons (only for custom themes)
            if (!isBuiltIn)
            {
                var editButton = new Wpf.Ui.Controls.Button
                {
                    Content = "Edit",
                    Margin = new Thickness(4, 0, 4, 0),
                    Tag = customTheme,
                    Appearance = Wpf.Ui.Controls.ControlAppearance.Primary
                };
                editButton.Click += EditThemeButton_Click;
                Grid.SetColumn(editButton, 2);
                grid.Children.Add(editButton);

                var deleteButton = new Wpf.Ui.Controls.Button
                {
                    Content = "Delete",
                    Appearance = Wpf.Ui.Controls.ControlAppearance.Danger,
                    Margin = new Thickness(4, 0, 0, 0),
                    Tag = customTheme
                };
                deleteButton.Click += DeleteThemeButton_Click;
                Grid.SetColumn(deleteButton, 3);
                grid.Children.Add(deleteButton);
            }

            return grid;
        }

        private void ThemeRadioButton_Checked(object sender, RoutedEventArgs e, string themeTag)
        {
            mainWindow.ApplyTheme(themeTag);
            currentTheme = themeTag;
            SaveSettings();

            // Update button backgrounds in settings window
            UpdateButtonBackgrounds(themeTag);
        }

        private void CreateThemeButton_Click(object sender, RoutedEventArgs e)
        {
            // Open theme creator window
            var themeCreator = new ThemeCreatorWindow(mainWindow);
            if (themeCreator.ShowDialog() == true)
            {
                // Refresh the themes panel
                LoadAllThemesIntoPanel();
            }
        }

        private void EditThemeButton_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Wpf.Ui.Controls.Button;
            if (button?.Tag is CustomTheme theme)
            {
                // Open theme creator window with existing theme
                var themeCreator = new ThemeCreatorWindow(mainWindow, theme);
                if (themeCreator.ShowDialog() == true)
                {
                    // Refresh the themes panel
                    LoadAllThemesIntoPanel();
                }
            }
        }

        private void DeleteThemeButton_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Wpf.Ui.Controls.Button;
            if (button?.Tag is CustomTheme theme)
            {
                var result = System.Windows.MessageBox.Show(
                    $"Are you sure you want to delete the theme '{theme.Name}'?",
                    "Delete Theme",
                    System.Windows.MessageBoxButton.YesNo,
                    System.Windows.MessageBoxImage.Warning);

                if (result == System.Windows.MessageBoxResult.Yes)
                {
                    // Delete the theme
                    mainWindow.DeleteCustomTheme(theme.Name);
                    
                    // If the deleted theme was current, switch to Light
                    if (currentTheme == theme.Name)
                    {
                        mainWindow.ApplyTheme("Light");
                        currentTheme = "Light";
                        SaveSettings();
                    }
                    
                    // Refresh the themes panel
                    LoadAllThemesIntoPanel();
                }
            }
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var settings = new SettingsData
                {
                    Theme = currentTheme
                };

                var settingsFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "aflex_lite", "settings.json");
                var json = System.Text.Json.JsonSerializer.Serialize(settings, new System.Text.Json.JsonSerializerOptions
                {
                    WriteIndented = true
                });
                File.WriteAllText(settingsFile, json);

                // Save theme to main window for persistence
                mainWindow.SaveCurrentTheme(currentTheme);

                this.Close();
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show($"Error saving settings: {ex.Message}", "Error", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
            }
        }

        private void CloseButton_Click(object sender, RoutedEventArgs e)
        {
            // Revert to saved theme if user cancels
            LoadSettings();
            mainWindow.ApplyTheme(currentTheme);
            this.Close();
        }

        private void SaveSettings()
        {
            try
            {
                var settingsFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "aflex_lite", "settings.json");
                var settings = new SettingsData { Theme = currentTheme };
                var json = System.Text.Json.JsonSerializer.Serialize(settings, new System.Text.Json.JsonSerializerOptions { WriteIndented = true });
                File.WriteAllText(settingsFile, json);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error saving settings: {ex.Message}");
            }
        }

        private void Hyperlink_RequestNavigate(object sender, System.Windows.Navigation.RequestNavigateEventArgs e)
        {
            Process.Start(new ProcessStartInfo(e.Uri.AbsoluteUri) { UseShellExecute = true });
            e.Handled = true;
        }

        private void TitleBar_MouseLeftButtonDown(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            if (e.ButtonState == System.Windows.Input.MouseButtonState.Pressed)
            {
                DragMove();
            }
        }

        private void MinimizeButton_Click(object sender, RoutedEventArgs e)
        {
            WindowState = WindowState.Minimized;
        }

        private void TitleCloseButton_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }
    }

    public class SettingsData
    {
        public string? Theme { get; set; }
    }
}