ZRAM can significantly improve system performance by compressing and decompressing memory pages, reducing the need to swap to slower disk storage.

Features:
- Easily turn on/off ZRAM compression to optimize memory usage.
- Check the current status and utilization of ZRAM.
- Fine-tune ZRAM parameters for optimal performance.
- User-friendly command-line interface with clear instructions.

Usage:
1. Clone this repository to your local machine.
2. Run the script with appropriate options to control ZRAM settings.
3. Enjoy improved system responsiveness and memory utilization.

Why should we use zram ?
- It's simple because you will have more ram (in cost of a little more power consumption) {but it worth it}
zram allow me to have more than 30 browser tabs on a low-ram system without getting killed by OOM 

```

               total        used        free      shared    buff/cache   available
Mem:           3.7Gi       2.4Gi      825Mi    307Mi        1.1Gi           1.3Gi
Swap:          2.0Gi       874Mi       1.1Gi
 
NAME          ALGORITHM        DISKSIZE         DATA    COMPR    TOTAL    STREAMS      MOUNTPOINT
/dev/zram0       zstd            2G            874.2M  139.6M   153.6M       2            [SWAP]
```

Whether you're a power user looking to fine-tune your system or a beginner seeking an efficient way to manage memory, this script provides a simple yet powerful solution.

Please note that this script is designed for Linux systems that support ZRAM. Use it responsibly and consider testing in a safe environment before making changes to critical systems.

Let's optimize your memory management with ZRAM! 🚀
