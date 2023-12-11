using Sepia.Desktop.Abstraction;

namespace Sepia.Desktop.Sepia;

internal sealed class LowLevelSepiaFilter : SepiaFilter
{
    public override Task<double> Benchmark(Image inputImage, double intensity, int threads, int iterations)
    {
        throw new NotImplementedException();
    }

    public override Task<Image> Process(Image inputImage, double intensity, int threads)
    {
        throw new NotImplementedException();
    }
}
