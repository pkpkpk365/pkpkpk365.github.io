import time
from playwright.sync_api import sync_playwright

URLS = [
    "https://example.com/video1",
    "https://example.com/video2",
]

USER_DATA_DIR = "edge_profile"

JS_PLAY = r'''
(() => {
  document.querySelectorAll("video").forEach(v => {
    v.muted = true;
    v.play().catch(() => {});
  });
  const btn = document.querySelector(
    'button[aria-label*=play i], .ytp-play-button, .vjs-play-control, .plyr__control[data-plyr="play"]'
  );
  if (btn) btn.click();
})();
'''

def process_page(page, url):
    page.goto(url, wait_until="domcontentloaded", timeout=60000)
    page.wait_for_timeout(2500)
    page.evaluate(JS_PLAY)

    for _ in range(60):
        state = page.evaluate("""
        () => {
          const v = document.querySelector("video");
          if (!v) return "no-video";
          if (v.ended) return "ended";
          if (!v.paused) return "playing";
          return "paused";
        }
        """)
        print(url, state)
        if state == "ended":
            break
        if state == "paused":
            page.evaluate(JS_PLAY)
        time.sleep(3)

with sync_playwright() as p:
    browser = p.chromium.launch_persistent_context(
        user_data_dir=USER_DATA_DIR,
        channel="msedge",
        headless=False
    )
    page = browser.new_page()

    for url in URLS:
        process_page(page, url)

    browser.close()
