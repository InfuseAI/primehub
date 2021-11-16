FROM python:3.7.2-slim

EXPOSE 8501

WORKDIR /streamlit

RUN pip install --upgrade pip
RUN pip install streamlit==1.2.0

ENTRYPOINT [ "streamlit" ]

