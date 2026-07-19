import os
os.environ["PEXELS_API_KEY"] = "qT5dXpgFFFlshWGOJ23nePtcEx9kqA0CxfqbD94NG4lNXN89MZUxe9ub"

import sys
sys.path.insert(0, r"E:\opencode-tools\openmontage")

from tools.tool_registry import registry
import json
registry.discover()
summary = registry.provider_menu_summary()
for cap in summary["capabilities"]:
    if cap["capability"] in ("video_generation", "image_generation", "music_search", "clip_retrieval", "corpus_population", "tts"):
        print(f'{cap["capability"]}: {cap["configured"]}/{cap["total"]} configured')
        if cap["available_providers"]:
            print(f'  Available: {cap["available_providers"]}')
        else:
            print(f'  None available. Unlock with: {[p["provider"] for p in summary["setup_offers"] if p["capability"] == cap["capability"]]}')
