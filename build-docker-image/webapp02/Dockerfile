FROM ubuntu

RUN apt-get update && apt-get -y install python3 python3-pip elinks net-tools

RUN pip3 install flask --trusted-host=pypi.python.org --trusted-host=pypi.org --trusted-host=files.pythonhosted.org

COPY app.py /opt/source-code/

CMD [ "python3", "/opt/source-code/app.py"]
