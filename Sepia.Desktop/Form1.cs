using Sepia.Desktop.Abstraction;
using Sepia.Desktop.Sepia;

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

        // TODO: Check if file exists
        private void button1_Click(object sender, EventArgs e)
        {
            var openFileDialog = new OpenFileDialog();
            var result = openFileDialog.ShowDialog();
            if (result != DialogResult.OK) return;

            _targetImagePath = openFileDialog.FileName;
            _targetImage = Image.FromFile(_targetImagePath);

            pictureBoxOriginal.Image = _targetImage;
            pictureBoxSepia.Image = null;
            button2.Enabled = true;
            benchmarkLabel.Text = string.Empty;
        }

        private async void button2_Click(object sender, EventArgs e)
        {
            var sepiaFilter = GetSepiaFilter();

            var intensity = Convert.ToDouble(trackBarSepiaIntensity.Value) / 100.0;
            var threads = trackBarThreads.Value;

            var result = await sepiaFilter.Process(_targetImage, intensity, threads);
            pictureBoxSepia.Image = result;

            var benchmarkMilliseconds = await sepiaFilter.Benchmark(_targetImage, intensity, threads, BenchmarkIterations);
            benchmarkLabel.Text = benchmarkMilliseconds.ToString();
        }
    }
}