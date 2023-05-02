FROM python:3.9-slim-buster

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY requirements.txt .
# install python dependencies
RUN pip install --upgrade pip \
 && pip install --ignore-installed -r requirements.txt

COPY src ./src

# running migrations
RUN python src/manage.py migrate

# gunicorn
# CMD ["gunicorn", "--config", "gunicorn-cfg.py", "app.wsgi"]
CMD ["python", "src/manage.py", "runserver", "0.0.0.0:8000"]
