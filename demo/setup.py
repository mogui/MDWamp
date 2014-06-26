from setuptools import setup

setup(
   name = 'hello',
   version = '0.0.1',
   description = "'hello' WAMP Component",
   platforms = ['Any'],
   packages = 'hello',
   include_package_data = True,
   zip_safe = False,
   entry_points = {
      'autobahn.twisted.wamplet': [
         'backend = hello.hello:AppSession'
      ],
   }
)