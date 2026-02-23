import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()
url = os.environ.get("SUPABASE_URL")
key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")

supabase = create_client(url, key)

try:
    user = supabase.auth.admin.create_user({
        "email": "tester0@example.com",
        "password": "password123",
        "email_confirm": True
    })
    print("User created!")
except Exception as e:
    print("Error:", e)
