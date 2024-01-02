using Sepia.Desktop.Abstraction;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace Sepia.Desktop.Sepia;

internal sealed class LowLevelSepiaFilter : SepiaFilter
{
    public override async Task<double> Benchmark(Image inputImage, double intensity, int threads, int iterations)
    {
        var millisecondsSum = 0.0d;
        var stopwatch = new Stopwatch();

        for (var iteration = 0; iteration < iterations; iteration += 1)
        {
            stopwatch.Start();

            await Process(inputImage, intensity, threads, (image, startingPixelIndex, pixelCount, intensity) =>
            {
                ProcessPart(image, startingPixelIndex, pixelCount, intensity);
                return Task.CompletedTask;
            });

            stopwatch.Stop();
            millisecondsSum += stopwatch.ElapsedMilliseconds;
            stopwatch.Restart();
        }

        return millisecondsSum / iterations;
    }

    public override async Task<Image> Process(Image inputImage, double intensity, int threads)
    {
        return await Process(inputImage, intensity, threads, (image, startingPixelIndex, pixelCount, intensity) =>
        {
            ProcessPart(image, startingPixelIndex, pixelCount, intensity);
            return Task.CompletedTask;
        });
    }

    [DllImport(@"C:\Studia\JA\Sepia\x64\Debug\Sepia.AsmLib.dll")]
    public static extern void ProcessPart(byte[] image, int startingPixelIndex, int pixelCount, double intensity);
}
