FROM python:3.9.10

#Setting timezone
ENV TZ Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#Construct the home directory and work directory
RUN addgroup --gid 1001 app 
RUN useradd -u 1001 \
            -G app \
            -d /home/app/workdir \
            -s /sbin/nologin \
            -g app \
            app

#Create an app user for the application usage
ENV APP_HOME=/home/app/workdir/

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
RUN chown -R app:app $APP_HOME

COPY ./docker/requirements.txt $APP_HOME/docker/requirements.txt
RUN pip3 --no-cache-dir install -r $APP_HOME/docker/requirements.txt

# Copy project folder
COPY . $APP_HOME