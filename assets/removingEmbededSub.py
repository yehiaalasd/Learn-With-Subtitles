import cv2
import pytesseract
import sys
import os

def remove_subtitles(video_path, output_path):
    if not os.path.exists(video_path):
        print(f"Error: Video file {video_path} does not exist.")
        return

    cap = cv2.VideoCapture(video_path)
    fourcc = cv2.VideoWriter_fourcc(*'XVID')
    out = cv2.VideoWriter(output_path, fourcc, 20.0, (int(cap.get(3)), int(cap.get(4))))

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        # Use Tesseract to detect text
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        boxes = pytesseract.image_to_boxes(gray)

        for b in boxes.splitlines():
            b = b.split(' ')
            x, y, w, h = int(b[1]), int(b[2]), int(b[3]), int(b[4])
            # Blur the text areas
            frame[y:h, x:w] = cv2.blur(frame[y:h, x:w], (23, 23))

        out.write(frame)

    cap.release()
    out.release()

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python removingEmbededSub.py <video_path> <output_path>")
        sys.exit(1)

    video_path = sys.argv[1]
    output_path = os.path.join(sys.argv[2], 'output_video.mp4')  # Adjust output path as needed
    remove_subtitles(video_path, output_path)