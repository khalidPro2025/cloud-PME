function testAPI() {
  fetch('/api/')
    .then(response => response.json())
    .then(data => {
      document.getElementById('result').textContent =
        JSON.stringify(data, null, 2);
    });
}
