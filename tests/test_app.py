import re
from datetime import datetime
import pytz

def test_index_page(client):
    """Test the index page loads and contains expected elements."""
    response = client.get('/')
    assert response.status_code == 200
    
    # Test that the page contains our main elements
    html_content = response.data.decode()
    assert 'Dadboard' in html_content
    assert 'Total Visits' in html_content
    assert 'Current UTC Time' in html_content

def test_counter_increments(client):
    """Test that the counter increments with each page visit."""
    # First visit
    response1 = client.get('/')
    html1 = response1.data.decode()
    counter1 = int(re.search(r'<div class="stat-value counter-value">(\d+)</div>', html1).group(1))
    
    # Second visit
    response2 = client.get('/')
    html2 = response2.data.decode()
    counter2 = int(re.search(r'<div class="stat-value counter-value">(\d+)</div>', html2).group(1))
    
    # Counter should increment by 1
    assert counter2 == counter1 + 1

def test_utc_time_format(client):
    """Test that the UTC time is in the correct format and is current."""
    response = client.get('/')
    html_content = response.data.decode()
    
    # Extract time from the response using regex
    time_match = re.search(r'<div class="stat-value time-value">(.*?)</div>', html_content)
    assert time_match is not None
    
    time_str = time_match.group(1)
    # Verify the time string format (YYYY-MM-DD HH:MM:SS UTC)
    assert re.match(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} UTC', time_str)
    
    # Parse the time and verify it's within 1 minute of current time
    displayed_time = datetime.strptime(time_str, '%Y-%m-%d %H:%M:%S UTC')
    current_time = datetime.now(pytz.UTC)
    time_difference = abs((current_time.replace(tzinfo=None) - displayed_time).total_seconds())
    
    assert time_difference < 60  # Time should be within 60 seconds of current time

def test_page_content_type(client):
    """Test that the page is served as HTML."""
    response = client.get('/')
    assert response.content_type == 'text/html; charset=utf-8'

def test_page_accessibility(client):
    """Test basic accessibility features of the page."""
    response = client.get('/')
    html_content = response.data.decode()
    
    # Check for important HTML accessibility features
    assert '<html lang="en">' in html_content
    assert '<meta charset="UTF-8">' in html_content
    assert '<meta name="viewport"' in html_content 