import uvicorn
import logging
from app.server import build_app

logger = logging.getLogger(__name__)

app = build_app()

uvicorn.run(app, host="0.0.0.0", port=8080)
