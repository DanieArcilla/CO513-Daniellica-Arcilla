Mechanical pushbuttons do not produce a clean, instant transition when pressed or released. Instead, the contacts bounce rapidly for a few milliseconds, causing multiple unwanted transitions. Without debouncing, a single press could be interpreted as several presses by the processor.

This program implements software debouncing. When a key press is detected, the program waits for a short delay (approximately 5 ms) using a busy-wait loop, then reads the key again to confirm that it is still pressed. If the signal is stable, the input is considered a valid press. The program then waits until the key is fully released before accepting another press. This ensures that each physical button press is registered exactly once.

Here's the link for my simulation video:

https://youtu.be/7Y2JCRCpxOg
