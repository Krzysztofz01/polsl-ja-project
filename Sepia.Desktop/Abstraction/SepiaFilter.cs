using System.Runtime.InteropServices;

namespace Sepia.Desktop.Abstraction;

public abstract class SepiaFilter
{
    public abstract Task<Image> Process(Image inputImage, double intensity, int threads);
    public abstract Task<double> Benchmark(Image inputImage, double intensity, int threads, int iterations);

    protected static async Task<Image> Process(Image inputImage, double intensity, int threads, Func<byte[], int, int, double, Task> processDelegate)
    {
        var bitmap = new Bitmap(inputImage);
        var bitmapData = bitmap.LockBits(new Rectangle(0, 0, inputImage.Width, inputImage.Height), System.Drawing.Imaging.ImageLockMode.ReadWrite, System.Drawing.Imaging.PixelFormat.Format32bppArgb);

        var stride = bitmapData.Stride;
        var data = new byte[stride * bitmap.Height];
        Marshal.Copy(bitmapData.Scan0, data, 0, data.Length);

        var processParts = new List<Task>();

        var pixelsPerThread = (data.Length / 4) / threads;
        var pixelsPerThreadLeft = (data.Length / 4) % threads;

        for (var threadIndex = 0; threadIndex < threads; threadIndex += 1)
        {
            var startingIndex = threadIndex * pixelsPerThread;
            var pixelsForCurrentThread = (threadIndex == threads - 1) ? pixelsPerThread + pixelsPerThreadLeft : pixelsPerThread;

            processParts.Add(processDelegate.Invoke(data, startingIndex, pixelsForCurrentThread, intensity));
        }

        await Task.WhenAll(processParts);

        Marshal.Copy(data, 0, bitmapData.Scan0, data.Length);
        bitmap.UnlockBits(bitmapData);

        return bitmap;
    }
}
