from flask import Flask, render_template
from datetime import datetime
import os
import pytz

app = Flask(__name__)

# Global counter variable
visit_counter = 0

@app.route('/')
def index():
    global visit_counter
    visit_counter += 1
    
    # Get current UTC time
    utc_time = datetime.now(pytz.UTC).strftime('%Y-%m-%d %H:%M:%S UTC')
    
    return render_template('index.html', counter=visit_counter, utc_time=utc_time)

if __name__ == '__main__':
    debug_mode = os.environ.get('FLASK_DEBUG', 'false').lower() == 'true'
    app.run(debug=debug_mode)