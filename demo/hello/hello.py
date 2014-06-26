from autobahn.twisted.wamp import ApplicationSession

class AppSession(ApplicationSession):

   def onJoin(self, details):

      def hello():
         return u'Hello from Python!'

      self.register(hello, 'com.hello.hello')
