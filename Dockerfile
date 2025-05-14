FROM python:3.9-alpine3.21

RUN adduser \
    --disabled-password \
    --home /home/app_user \
    --shell /bin/bash \
    app_user

WORKDIR /home/app_user

COPY Pipfile Pipfile.lock ./

RUN pip install --no-cache-dir --upgrade pip==24.0 && \
    pip install --no-cache-dir pipenv==2023.12 && \
    pipenv install --system --deploy 

RUN pip install psycopg2-binary

ENV PORT=8080

USER app_user

COPY . .

CMD ["python", "main.py"]
