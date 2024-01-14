using Sepia.Abstraction;
using System.Diagnostics;
using System.Drawing;
using System.Runtime.Versioning;

namespace Sepia.HighLevelSepia;

[SupportedOSPlatform("windows")]
public sealed class HighLevelSepiaFilter : SepiaFilter
{
    public override async Task<Image> Process(Image inputImage, double intensity, int threads)
    {
        return await Process(inputImage, intensity, threads, (image, startingPixelIndex, pixelCount, intensity) =>
        {
            return ProcessPart(image, startingPixelIndex, pixelCount, intensity);
        });
    }

    public override async Task<double> Benchmark(Image inputImage, double intensity, int threads, int iterations)
    {
        var millisecondsSum = 0.0d;
        var stopwatch = new Stopwatch();

        for (var iteration = 0; iteration < iterations; iteration += 1)
        {
            stopwatch.Start();

            await Process(inputImage, intensity, threads, (image, startingPixelIndex, pixelCount, intensity) =>
            {
                return ProcessPart(image, startingPixelIndex, pixelCount, intensity);
            });

            stopwatch.Stop();
            millisecondsSum += stopwatch.ElapsedMilliseconds;
            stopwatch.Restart();
        }

        return millisecondsSum / iterations;
    }

    private static Task ProcessPart(byte[] image, int startingPixelIndex, int pixelCount, double intensity)
    {
        byte r, g, b;
        double or, og, ob;

        for (var index = 0; index < pixelCount; index += 1)
        {
            var offset = (index + startingPixelIndex) * 4;

            b = image[offset + 0];
            g = image[offset + 1];
            r = image[offset + 2];

            or = Math.Min(255, Math.Max(0, r * 0.39 + g * 0.77 + b * 0.19));
            og = Math.Min(255, Math.Max(0, r * 0.35 + g * 0.69 + b * 0.17));
            ob = Math.Min(255, Math.Max(0, r * 0.27 + g * 0.53 + b * 0.13));

            or = Math.Min(255, Math.Max(0, or * intensity + r * (1.0 - intensity)));
            og = Math.Min(255, Math.Max(0, og * intensity + g * (1.0 - intensity)));
            ob = Math.Min(255, Math.Max(0, ob * intensity + b * (1.0 - intensity)));

            image[offset + 0] = Convert.ToByte(ob);
            image[offset + 1] = Convert.ToByte(og);
            image[offset + 2] = Convert.ToByte(or);
        }

        return Task.CompletedTask;
    }
}
