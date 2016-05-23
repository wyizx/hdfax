# coding:utf-8
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import mimetypes
import os
import re
import smtplib
import sys


class EmailUtil():

    mail_host = "smtp.163.com"  # 设置服务器
    mail_user = "henginet"  # 用户名
    mail_pass = "chenzhibing"  # 口令
    mail_postfix = "163.com"  # 发件箱的后缀
    me = "hiveclient01<%s@%s>" % (mail_user, mail_postfix)

    @staticmethod
    def send(to_list, sub, content, filenames = None, retry = None):
        if retry is None :
            EmailUtil.__send(to_list, sub, content, filenames)
        else :
            count = 0
            while True :
                if count == retry :
                    break
                if EmailUtil._send(to_list, sub, content, filenames) == False :
                    count += 1

    @staticmethod
    def __send(to_list, sub, content, filenames = None):
        message = MIMEMultipart()
        message.attach(MIMEText(content, _subtype = 'plain', _charset = 'UTF-8'))
        message["Subject"] = sub
        message["From"] = EmailUtil.me
        message["To"] = ";".join(to_list)
        if filenames is not None :
            for filename in filenames :
                if os.path.exists(filename):
                    ctype, encoding = mimetypes.guess_type(filename)
                    if ctype is None or encoding is not None:
                        ctype = "application/octet-stream"
                    subtype = ctype.split("/", 1)
                    attachment =  MIMEText(open(filename, 'rb').read(), 'base64', 'utf-8')
                    attachment["Content-Type"] = 'application/octet-stream'
                    # print "filename"
                    # print filename
                    filename = filename.split("/")[-1]
                    # print "filename.split"
                    # print filename
                    attachment["Content-Disposition"] = 'attachment; filename="'+filename+'"'
                    message.attach(attachment)
        try:
            server = smtplib.SMTP()
            server.connect(EmailUtil.mail_host)
            server.login(EmailUtil.mail_user, EmailUtil.mail_pass)
            server.sendmail(EmailUtil.me, to_list, message.as_string())
            server.close()
            return True
        except Exception, e:
            print str(e)
        return False

if __name__ == '__main__':
    # print sys.argv[0]#system parameter
    # print sys.argv[1]#email receiver addr !!!one receiver only!!!
    # print sys.argv[2]#subject
    # print sys.argv[3]#content
    # print sys.argv[4]#attachment dir
    EmailUtil.send([sys.argv[1]],
                 sys.argv[2],
                 sys.argv[3],
                 [sys.argv[4]]
                 )
