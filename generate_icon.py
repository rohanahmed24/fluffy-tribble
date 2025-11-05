#!/usr/bin/env python3
"""
Generate a custom app icon for the Ideogram app with premium purple gradient
"""

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("PIL not available, installing...")
    import subprocess
    subprocess.check_call(['pip3', 'install', 'pillow'])
    from PIL import Image, ImageDraw, ImageFont

import math

def create_gradient_icon(size=1024):
    """Create a beautiful gradient icon with geometric shapes"""

    # Create image with transparency
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Define premium colors (matching PremiumTheme)
    colors = [
        (123, 44, 191),   # royalPurple #7B2CBF
        (157, 78, 221),   # vibrantPurple #9D4EDD
        (199, 125, 255),  # softLavender #C77DFF
    ]

    # Draw gradient background
    for y in range(size):
        # Calculate color interpolation
        ratio = y / size
        if ratio < 0.5:
            # Interpolate between color 0 and 1
            t = ratio * 2
            r = int(colors[0][0] * (1-t) + colors[1][0] * t)
            g = int(colors[0][1] * (1-t) + colors[1][1] * t)
            b = int(colors[0][2] * (1-t) + colors[1][2] * t)
        else:
            # Interpolate between color 1 and 2
            t = (ratio - 0.5) * 2
            r = int(colors[1][0] * (1-t) + colors[2][0] * t)
            g = int(colors[1][1] * (1-t) + colors[2][1] * t)
            b = int(colors[1][2] * (1-t) + colors[2][2] * t)

        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    # Create a rounded rectangle mask for modern look
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    corner_radius = size // 5
    mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)

    # Apply mask
    img.putalpha(mask)

    # Draw geometric shapes for visual interest
    center_x, center_y = size // 2, size // 2

    # Draw outer glow circle
    glow_size = int(size * 0.4)
    for i in range(10):
        alpha = int(50 - i * 5)
        offset = i * 3
        draw.ellipse(
            [center_x - glow_size - offset, center_y - glow_size - offset,
             center_x + glow_size + offset, center_y + glow_size + offset],
            outline=(255, 255, 255, alpha),
            width=3
        )

    # Draw central circle with gradient
    circle_size = int(size * 0.35)
    draw.ellipse(
        [center_x - circle_size, center_y - circle_size,
         center_x + circle_size, center_y + circle_size],
        fill=(255, 255, 255, 30),
        outline=(255, 255, 255, 100),
        width=4
    )

    # Draw sparkle/star icon in center
    sparkle_size = int(size * 0.2)
    points = []
    for i in range(8):
        angle = i * math.pi / 4
        if i % 2 == 0:
            # Outer points
            x = center_x + int(sparkle_size * math.cos(angle))
            y = center_y + int(sparkle_size * math.sin(angle))
        else:
            # Inner points
            x = center_x + int(sparkle_size * 0.4 * math.cos(angle))
            y = center_y + int(sparkle_size * 0.4 * math.sin(angle))
        points.append((x, y))

    draw.polygon(points, fill=(255, 255, 255, 255))

    # Add inner glow to star
    for i in range(3):
        offset = i * 2
        inner_points = [(p[0] - offset if idx % 2 == 0 else p[0] + offset,
                        p[1] - offset if idx % 2 == 0 else p[1] + offset)
                       for idx, p in enumerate(points)]
        draw.polygon(inner_points, fill=(255, 215, 0, 150 - i * 30))

    # Add decorative corner elements
    corner_size = int(size * 0.1)
    corners = [
        (corner_size, corner_size),  # Top-left
        (size - corner_size, corner_size),  # Top-right
        (corner_size, size - corner_size),  # Bottom-left
        (size - corner_size, size - corner_size),  # Bottom-right
    ]

    for cx, cy in corners:
        draw.ellipse(
            [cx - 15, cy - 15, cx + 15, cy + 15],
            fill=(255, 255, 255, 80)
        )

    return img

def main():
    """Generate icons for all required sizes"""
    print("Generating custom app icon...")

    # Generate base icon
    base_icon = create_gradient_icon(1024)

    # Save base icon
    base_icon.save('assets/images/app_icon.png')
    print("✓ Created base icon: assets/images/app_icon.png")

    # Android icon sizes
    android_sizes = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
    }

    for density, size in android_sizes.items():
        resized = base_icon.resize((size, size), Image.Resampling.LANCZOS)
        path = f'android/app/src/main/res/mipmap-{density}/ic_launcher.png'
        resized.save(path)
        print(f"✓ Created {density} icon ({size}x{size}): {path}")

    print("\n✅ All icons generated successfully!")
    print("Icons feature a premium purple gradient with a sparkle design")

if __name__ == '__main__':
    main()
