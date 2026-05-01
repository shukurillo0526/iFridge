import asyncio
import httpx

async def test_ollama():
    prompt = "Hello, testing Ollama."
    messages = [{"role": "user", "content": prompt}]
    payload = {
        "model": "qwen3:8b",
        "messages": messages,
        "stream": False,
        "options": {
            "temperature": 0.1,
            "num_predict": 1024,
        },
    }
    
    async with httpx.AsyncClient() as client:
        resp = await client.post("http://localhost:11434/api/chat", json=payload)
        print("Status code:", resp.status_code)
        if resp.status_code == 200:
            print("Response:", resp.json())
        else:
            print("Error:", resp.text)

if __name__ == "__main__":
    asyncio.run(test_ollama())
