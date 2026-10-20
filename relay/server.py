import asyncio
import json
import os
import time
from urllib.parse import urlparse

from websockets.exceptions import ConnectionClosed
from websockets.legacy.server import serve

MAX_MESSAGE_BYTES = 4096
MAX_CONNECTIONS = 500
MAX_RATE_PER_SECOND = 12
CLIENTS = set()
RATE = {}

async def handler(ws, path=None):
    if len(CLIENTS) >= MAX_CONNECTIONS:
        await ws.close(code=1013, reason="capacity")
        return
    CLIENTS.add(ws)
    try:
        async for raw in ws:
            if len(raw.encode("utf-8")) > MAX_MESSAGE_BYTES:
                await ws.close(code=1009, reason="message too large")
                break
            try:
                message = json.loads(raw)
            except (TypeError, ValueError):
                continue
            if not isinstance(message, dict):
                continue
            kind = message.get("type")
            if kind == "hello":
                ws.display_name = str(message.get("name", ""))[:48]
                ws.character_name = ws.display_name.casefold()
                continue
            if kind == "lyric":
                sender = str(message.get("sender", ""))[:64]
                text = str(message.get("text", ""))[:350]
                sender_name = str(getattr(ws, "display_name", ""))[:48]
                seq = message.get("seq")
                if not sender or not text or not isinstance(seq, int):
                    continue
                now = time.monotonic()
                events = [stamp for stamp in getattr(ws, "rate_events", []) if now - stamp < 1.0]
                if len(events) >= MAX_RATE_PER_SECOND:
                    ws.rate_events = events
                    continue
                events.append(now)
                ws.rate_events = events
                payload = json.dumps({"type":"lyric", "sender":sender, "sender_name":sender_name, "seq":seq, "text":text}, ensure_ascii=False)
            elif kind == "jam_invite":
                invite_id = str(message.get("invite_id", ""))[:64]
                sender_name = str(message.get("sender_name", ""))[:48]
                recipients = message.get("recipients")
                url = str(message.get("url", ""))[:512]
                host = (urlparse(url).hostname or "").lower()
                recent = [stamp for stamp in getattr(ws, "jam_events", []) if time.monotonic() - stamp < 60]
                if len(recent) >= 3 or sender_name.casefold() != getattr(ws, "character_name", ""):
                    ws.jam_events = recent
                    continue
                if not invite_id or not sender_name or not isinstance(recipients, list) or not recipients or host not in {"open.spotify.com", "spotify.link"}:
                    continue
                recent.append(time.monotonic())
                ws.jam_events = recent
                clean_recipients = [str(name)[:48] for name in recipients[:40] if str(name).strip()]
                if not clean_recipients:
                    continue
                message["_targets"] = [name.casefold() for name in clean_recipients]
                payload = json.dumps({"type":"jam_invite", "invite_id":invite_id, "sender_name":sender_name, "recipients":clean_recipients, "url":url}, ensure_ascii=False)
            elif kind == "jam_response":
                invite_id = str(message.get("invite_id", ""))[:64]
                sender_name = str(message.get("sender_name", ""))[:48]
                target_name = str(message.get("target_name", ""))[:48]
                response = "accepted" if message.get("response") == "accepted" else "declined"
                if not invite_id or not sender_name or not target_name or sender_name.casefold() != getattr(ws, "character_name", ""):
                    continue
                message["_targets"] = [target_name.casefold()]
                payload = json.dumps({"type":"jam_response", "invite_id":invite_id, "sender_name":sender_name, "target_name":target_name, "response":response}, ensure_ascii=False)
            else:
                continue
            stale = []
            for peer in tuple(CLIENTS):
                try:
                    targets = message.get("_targets")
                    if targets is not None and getattr(peer, "character_name", "") not in targets:
                        continue
                    await peer.send(payload)
                except ConnectionClosed:
                    stale.append(peer)
            for peer in stale:
                CLIENTS.discard(peer)
    finally:
        CLIENTS.discard(ws)

async def health(path, request_headers):
    parsed = urlparse(path)
    if parsed.path == "/health":
        body = json.dumps({"status":"ok", "clients":len(CLIENTS)}).encode()
        return (200, [("Content-Type","application/json"), ("Content-Length",str(len(body)))], body)
    return None

async def main():
    port = int(os.environ.get("PORT", "10000"))
    async with serve(handler, "0.0.0.0", port, process_request=health, max_size=MAX_MESSAGE_BYTES, ping_interval=20, ping_timeout=20):
        print(f"SpotiWoW relay listening on {port}", flush=True)
        await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
