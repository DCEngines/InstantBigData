from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream
from kafka import SimpleProducer, KafkaClient
import configparser

class StdOutListener(StreamListener):
	def on_data(self, data):
        	producer.send_messages("twitterstream", data.encode('utf-8'))
	        print (data)
        	return True

	def on_error(self, status):
        	print (status)

if __name__ == '__main__':
	config = configparser.ConfigParser()
	config.read('twitter_app_credentials.txt')
	access_token = config['DEFAULT']['access_token']
	access_token_secret = config['DEFAULT']['access_token_secret']
	consumer_key = config['DEFAULT']['consumer_key']
	consumer_secret = config['DEFAULT']['consumer_secret']
	kafka_broker = config['DEFAULT']['kafka_broker']
	kafka = KafkaClient(kafka_broker)
	producer = SimpleProducer(kafka)
	listener = StdOutListener()
	auth = OAuthHandler(consumer_key, consumer_secret)
	auth.set_access_token(access_token, access_token_secret)
	stream = Stream(auth, listener)
	stream.filter(locations=[-180,-90,180,90], languages=['en'])
