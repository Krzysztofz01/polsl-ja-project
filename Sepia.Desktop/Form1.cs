using Sepia.Abstraction;
using Sepia.Desktop.Sepia;
using Sepia.HighLevelSepia;

namespace Sepia.Desktop
{
    public partial class Form1 : Form
    {
        private const int BenchmarkIterations = 5;

        private readonly SepiaFilter? _highLevelSepiaFilter = null;
        private readonly SepiaFilter? _lowLevelSepiaFilter = null;

        private string _targetImagePath = string.Empty;
        private Image? _targetImage = null;

        public Form1()
        {
            InitializeComponent();

            _highLevelSepiaFilter = new HighLevelSepiaFilter();
            _lowLevelSepiaFilter = new LowLevelSepiaFilter();

            comboBoxLib.DataSource = Enum.GetValues<LibEnum>()
                .ToArray();
        }

        private SepiaFilter GetSepiaFilter()
        {
            return comboBoxLib.SelectedItem switch
            {
                LibEnum.LowLevel => _lowLevelSepiaFilter!,
                LibEnum.HighLevel => _highLevelSepiaFilter!,
                _ => throw new InvalidOperationException("Unsupported sepia filter specified."),
            };
        }

        private void button1_Click(object sender, EventArgs e)
        {
            var openFileDialog = new OpenFileDialog();
            var result = openFileDialog.ShowDialog();
            if (result != DialogResult.OK) return;

            if (!File.Exists(openFileDialog.FileName))
            {
                MessageBox.Show("No file or corrupted file selected.", "Sepia error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            try
            {
                _targetImagePath = openFileDialog.FileName;
                _targetImage = Image.FromFile(_targetImagePath);

                pictureBoxOriginal.Image = _targetImage;
                button2.Enabled = true;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to select the the image. {ex.Message}", "Sepia error", MessageBoxButtons.OK, MessageBoxIcon.Error);

                pictureBoxOriginal.Image = null;
                button2.Enabled = false;
            }
            finally
            {
                pictureBoxSepia.Image = null;
                benchmarkLabel.Text = string.Empty;
            }
        }

        private async void button2_Click(object sender, EventArgs e)
        {
            var sepiaFilter = GetSepiaFilter();

            var intensity = Convert.ToDouble(trackBarSepiaIntensity.Value) / 100.0;
            var threads = trackBarThreads.Value;

            if (_targetImage is null)
            {
                MessageBox.Show("Can not continue beacuse no file or corrupted file selected.", "Sepia error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            try
            {
                var result = await sepiaFilter.Process(_targetImage, intensity, threads);
                pictureBoxSepia.Image = result;

                var benchmarkMilliseconds = await sepiaFilter.Benchmark(_targetImage, intensity, threads, BenchmarkIterations);
                benchmarkLabel.Text = benchmarkMilliseconds.ToString();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Image processing failed. {ex.Message}", "Sepia error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                pictureBoxSepia.Image = null;
                benchmarkLabel.Text = string.Empty;
            }
        }
    }
}