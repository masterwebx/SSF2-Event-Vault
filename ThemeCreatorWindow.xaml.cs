using System;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Drawing;
using Wpf.Ui.Controls;
using Microsoft.Win32;
using System.Text.Json;

namespace SSF2EventCompilerWPF
{
    public partial class ThemeCreatorWindow : FluentWindow
    {
        private MainWindow mainWindow;
        private CustomTheme currentTheme;

        public ThemeCreatorWindow(MainWindow mainWindow)
        {
            InitializeComponent();
            this.mainWindow = mainWindow;
            currentTheme = new CustomTheme();
            LoadDefaultValues();
            SetupEventHandlers();
            LoadIcon();
        }

        public ThemeCreatorWindow(MainWindow mainWindow, CustomTheme existingTheme)
        {
            InitializeComponent();
            this.mainWindow = mainWindow;
            currentTheme = existingTheme;

            // Ensure UI is fully loaded before setting values
            this.Loaded += (s, e) =>
            {
                LoadExistingThemeValues(existingTheme);
            };

            SetupEventHandlers();
            LoadIcon();
            Title = $"Edit Theme: {existingTheme.Name}";
            var titleBlock = TitleTextBlock;
            if (titleBlock != null)
            {
                titleBlock.Text = $"Edit Theme: {existingTheme.Name}";
            }
        }

        private void LoadIcon()
        {
            var iconPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "icon.ico");
            if (File.Exists(iconPath))
            {
                try
                {
                    using (var icon = new Icon(iconPath))
                    {
                        var bitmapSource = System.Windows.Interop.Imaging.CreateBitmapSourceFromHIcon(
                            icon.Handle,
                            System.Windows.Int32Rect.Empty,
                            System.Windows.Media.Imaging.BitmapSizeOptions.FromWidthAndHeight(16, 16));

                        TitleBarIcon.Source = bitmapSource;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Failed to load title bar icon: {ex.Message}");
                }
            }
        }

        private void LoadDefaultValues()
        {
            // Set default values
            ThemeNameTextBox.Text = "My Custom Theme";
            AccentColorTextBox.Text = "#39FF14"; // Neon green
            BackgroundColorTextBox.Text = "#1C1C1C"; // Dark background
            TextColorTextBox.Text = "#FFFFFF"; // White text

            // Update previews with default values
            UpdateColorPreview();
            UpdatePreview();
        }

        private void SetupEventHandlers()
        {
            // Color text changed events
            AccentColorTextBox.TextChanged += (s, e) => { UpdateColorPreview(); UpdatePreview(); };
            BackgroundColorTextBox.TextChanged += (s, e) => { UpdateColorPreview(); UpdatePreview(); };
            TextColorTextBox.TextChanged += (s, e) => { UpdateColorPreview(); UpdatePreview(); };

            // Theme name changed
            ThemeNameTextBox.TextChanged += (s, e) => UpdatePreview();

            // Button events
            SaveButton.Click += SaveButton_Click;
            CancelButton.Click += CancelButton_Click;
            ExportThemeButton.Click += ExportThemeButton_Click;
            ImportThemeButton.Click += ImportThemeButton_Click;

            // Window control events
            MinimizeButton.Click += MinimizeButton_Click;
            CloseButton.Click += CloseButton_Click;
        }

        private void LoadExistingThemeValues(CustomTheme theme)
        {
            // Load existing theme values
            ThemeNameTextBox.Text = theme.Name;
            AccentColorTextBox.Text = theme.AccentColor;
            BackgroundColorTextBox.Text = theme.BackgroundColor;
            TextColorTextBox.Text = theme.TextColor;
            // Update previews with loaded values
            UpdateColorPreview();
            UpdatePreview();        }

        private void UpdateColorPreview()
        {
            // Update accent color preview
            try
            {
                var color = System.Windows.Media.ColorConverter.ConvertFromString(AccentColorTextBox.Text);
                if (color != null)
                {
                    AccentColorPreview.Background = new SolidColorBrush((System.Windows.Media.Color)color);
                }
            }
            catch
            {
                // Invalid color, keep current preview
            }

            // Update background color preview
            try
            {
                var bgColor = System.Windows.Media.ColorConverter.ConvertFromString(BackgroundColorTextBox.Text);
                if (bgColor != null)
                {
                    BackgroundColorPreview.Background = new SolidColorBrush((System.Windows.Media.Color)bgColor);
                }
            }
            catch
            {
                // Invalid color, keep current preview
            }

            // Update text color preview
            try
            {
                var textColor = System.Windows.Media.ColorConverter.ConvertFromString(TextColorTextBox.Text);
                if (textColor != null)
                {
                    TextColorPreview.Background = new SolidColorBrush((System.Windows.Media.Color)textColor);
                }
            }
            catch
            {
                // Invalid color, keep current preview
            }
        }

        private void UpdatePreview()
        {
            try
            {
                // Update preview background
                var bgColor = System.Windows.Media.ColorConverter.ConvertFromString(BackgroundColorTextBox.Text);
                if (bgColor != null)
                {
                    PreviewBorder.Background = new SolidColorBrush((System.Windows.Media.Color)bgColor);
                }

                // Update preview text colors
                var textColor = System.Windows.Media.ColorConverter.ConvertFromString(TextColorTextBox.Text);
                if (textColor != null)
                {
                    var textBrush = new SolidColorBrush((System.Windows.Media.Color)textColor);
                    PreviewTitle.Foreground = textBrush;
                    PreviewText.Foreground = textBrush;
                }

                // Update preview button accent color
                var accentColor = System.Windows.Media.ColorConverter.ConvertFromString(AccentColorTextBox.Text);
                if (accentColor != null)
                {
                    PreviewButton.Background = new SolidColorBrush((System.Windows.Media.Color)accentColor);
                    PreviewButton.Foreground = System.Windows.Media.Brushes.White; // Ensure text is visible on colored background
                }
            }
            catch
            {
                // Invalid colors, keep current preview
            }
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(ThemeNameTextBox.Text))
            {
                System.Windows.MessageBox.Show("Please enter a theme name.", "Validation Error", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Warning);
                return;
            }

            // Create the custom theme
            currentTheme.Name = ThemeNameTextBox.Text;
            currentTheme.BaseTheme = "Dark"; // Always use dark base theme
            currentTheme.AccentColor = AccentColorTextBox.Text;
            currentTheme.BackgroundColor = BackgroundColorTextBox.Text;
            currentTheme.TextColor = TextColorTextBox.Text;

            // Save to custom themes file
            SaveCustomTheme(currentTheme);

            // Add to main window's theme list
            mainWindow.AddCustomTheme(currentTheme);

            // Apply the theme
            mainWindow.ApplyCustomTheme(currentTheme);

            this.DialogResult = true;
        }

        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = false;
        }

        private void ExportThemeButton_Click(object sender, RoutedEventArgs e)
        {
            // Create theme from current settings
            var exportTheme = new CustomTheme
            {
                Name = ThemeNameTextBox.Text,
                BaseTheme = "Dark", // Always use dark base theme
                AccentColor = AccentColorTextBox.Text,
                BackgroundColor = BackgroundColorTextBox.Text,
                TextColor = TextColorTextBox.Text
            };

            var saveFileDialog = new SaveFileDialog
            {
                Filter = "Theme files (*.theme.json)|*.theme.json|All files (*.*)|*.*",
                DefaultExt = ".theme.json",
                FileName = $"{exportTheme.Name.Replace(" ", "_")}.theme.json"
            };

            if (saveFileDialog.ShowDialog() == true)
            {
                try
                {
                    var json = JsonSerializer.Serialize(exportTheme, new JsonSerializerOptions { WriteIndented = true });
                    File.WriteAllText(saveFileDialog.FileName, json);
                    System.Windows.MessageBox.Show("Theme exported successfully!", "Export Complete", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Information);
                }
                catch (Exception ex)
                {
                    System.Windows.MessageBox.Show($"Error exporting theme: {ex.Message}", "Export Error", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
                }
            }
        }

        private void ImportThemeButton_Click(object sender, RoutedEventArgs e)
        {
            var openFileDialog = new OpenFileDialog
            {
                Filter = "Theme files (*.theme.json)|*.theme.json|All files (*.*)|*.*",
                DefaultExt = ".theme.json"
            };

            if (openFileDialog.ShowDialog() == true)
            {
                try
                {
                    var json = File.ReadAllText(openFileDialog.FileName);
                    var importedTheme = JsonSerializer.Deserialize<CustomTheme>(json);

                    if (importedTheme != null)
                    {
                        // Load the imported theme into the UI
                        ThemeNameTextBox.Text = importedTheme.Name;
                        AccentColorTextBox.Text = importedTheme.AccentColor;
                        BackgroundColorTextBox.Text = importedTheme.BackgroundColor ?? "#1C1C1C";
                        TextColorTextBox.Text = importedTheme.TextColor ?? "#FFFFFF";

                        UpdateColorPreview();
                        UpdatePreview();
                        System.Windows.MessageBox.Show("Theme imported successfully!", "Import Complete", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Information);
                    }
                }
                catch (Exception ex)
                {
                    System.Windows.MessageBox.Show($"Error importing theme: {ex.Message}", "Import Error", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
                }
            }
        }

        private void ShowColorPickerDialog(Wpf.Ui.Controls.TextBox targetTextBox)
        {
            // Create a simple color picker window
            var colorPickerWindow = new Window
            {
                Title = "Choose Color",
                Width = 400,
                Height = 300,
                WindowStartupLocation = WindowStartupLocation.CenterOwner,
                Owner = this,
                ResizeMode = ResizeMode.NoResize
            };

            var grid = new Grid();
            grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            grid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) });
            grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });

            // Color swatches
            var swatchesPanel = new WrapPanel
            {
                Margin = new Thickness(10),
                HorizontalAlignment = HorizontalAlignment.Center
            };

            // Common colors - curated selection without duplicates
            var commonColors = new[]
            {
                "#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF", "#00FFFF", "#FFA500", "#800080",
                "#FFC0CB", "#A52A2A", "#808080", "#000000", "#FFFFFF", "#39FF14", "#FF69B4", "#1E1E1E",
                "#4A90E2", "#7ED321", "#F5A623", "#D0021B", "#9013FE", "#50E3C2", "#B8E986", "#F8E71C",
                "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FECA57", "#FF9FF3", "#54A0FF", "#5F27CD"
            };

            foreach (var colorHex in commonColors)
            {
                var colorButton = new System.Windows.Controls.Button
                {
                    Width = 30,
                    Height = 30,
                    Margin = new Thickness(2),
                    Background = new SolidColorBrush((System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString(colorHex)),
                    BorderBrush = System.Windows.Media.Brushes.Black,
                    BorderThickness = new Thickness(1),
                    ToolTip = colorHex
                };

                colorButton.Click += (s, e) =>
                {
                    targetTextBox.Text = colorHex;
                    UpdateColorPreview();
                    UpdatePreview();
                    colorPickerWindow.Close();
                };

                swatchesPanel.Children.Add(colorButton);
            }

            Grid.SetRow(swatchesPanel, 1);
            grid.Children.Add(swatchesPanel);

            // Buttons
            var buttonPanel = new StackPanel
            {
                Orientation = Orientation.Horizontal,
                HorizontalAlignment = HorizontalAlignment.Right,
                Margin = new Thickness(10)
            };

            var cancelButton = new Wpf.Ui.Controls.Button
            {
                Content = "Cancel",
                Margin = new Thickness(0, 0, 10, 0)
            };
            cancelButton.Click += (s, e) => colorPickerWindow.Close();

            var customButton = new Wpf.Ui.Controls.Button
            {
                Content = "Custom Hex",
                Appearance = Wpf.Ui.Controls.ControlAppearance.Primary
            };
            customButton.Click += (s, e) =>
            {
                var customColorDialog = new Window
                {
                    Title = "Enter Custom Color",
                    Width = 300,
                    Height = 150,
                    WindowStartupLocation = WindowStartupLocation.CenterOwner,
                    Owner = colorPickerWindow,
                    ResizeMode = ResizeMode.NoResize
                };

                var customGrid = new Grid();
                customGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
                customGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });

                var customTextBox = new Wpf.Ui.Controls.TextBox
                {
                    Text = targetTextBox.Text,
                    Margin = new Thickness(10),
                    PlaceholderText = "Enter hex color (e.g., #FF0000)"
                };

                var customButtonPanel = new StackPanel
                {
                    Orientation = Orientation.Horizontal,
                    HorizontalAlignment = HorizontalAlignment.Right,
                    Margin = new Thickness(10)
                };

                var customCancelButton = new Wpf.Ui.Controls.Button
                {
                    Content = "Cancel",
                    Margin = new Thickness(0, 0, 10, 0)
                };
                customCancelButton.Click += (cs, ce) => customColorDialog.Close();

                var customOkButton = new Wpf.Ui.Controls.Button
                {
                    Content = "OK",
                    Appearance = Wpf.Ui.Controls.ControlAppearance.Primary
                };
                customOkButton.Click += (cs, ce) =>
                {
                    try
                    {
                        var testColor = (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString(customTextBox.Text);
                        targetTextBox.Text = customTextBox.Text;
                        UpdateColorPreview();
                        UpdatePreview();
                        colorPickerWindow.Close();
                        customColorDialog.Close();
                    }
                    catch
                    {
                        System.Windows.MessageBox.Show("Invalid color format. Please use hex format like #FF0000.", "Invalid Color", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Warning);
                    }
                };

                customButtonPanel.Children.Add(customCancelButton);
                customButtonPanel.Children.Add(customOkButton);

                Grid.SetRow(customTextBox, 0);
                Grid.SetRow(customButtonPanel, 1);
                customGrid.Children.Add(customTextBox);
                customGrid.Children.Add(customButtonPanel);

                customColorDialog.Content = customGrid;
                customColorDialog.ShowDialog();
            };

            buttonPanel.Children.Add(cancelButton);
            buttonPanel.Children.Add(customButton);

            Grid.SetRow(buttonPanel, 2);
            grid.Children.Add(buttonPanel);

            colorPickerWindow.Content = grid;
            colorPickerWindow.ShowDialog();
        }

        private void AccentColorPickerButton_Click(object sender, RoutedEventArgs e)
        {
            ShowColorPickerDialog(AccentColorTextBox);
        }

        private void BackgroundColorPickerButton_Click(object sender, RoutedEventArgs e)
        {
            ShowColorPickerDialog(BackgroundColorTextBox);
        }

        private void TextColorPickerButton_Click(object sender, RoutedEventArgs e)
        {
            ShowColorPickerDialog(TextColorTextBox);
        }

        private void SaveCustomTheme(CustomTheme theme)
        {
            try
            {
                var themesFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "custom_themes.json");
                var themes = LoadCustomThemes();

                // Remove existing theme with same name if it exists
                themes.RemoveAll(t => t.Name == theme.Name);

                // Add the new theme
                themes.Add(theme);

                var json = JsonSerializer.Serialize(themes, new JsonSerializerOptions { WriteIndented = true });
                File.WriteAllText(themesFile, json);
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show($"Error saving custom theme: {ex.Message}", "Save Error", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
            }
        }

        private System.Collections.Generic.List<CustomTheme> LoadCustomThemes()
        {
            var themesFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "custom_themes.json");
            if (File.Exists(themesFile))
            {
                try
                {
                    var json = File.ReadAllText(themesFile);
                    return JsonSerializer.Deserialize<System.Collections.Generic.List<CustomTheme>>(json) ?? new System.Collections.Generic.List<CustomTheme>();
                }
                catch
                {
                    return new System.Collections.Generic.List<CustomTheme>();
                }
            }
            return new System.Collections.Generic.List<CustomTheme>();
        }

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

        private void CloseButton_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = false;
        }
    }
}