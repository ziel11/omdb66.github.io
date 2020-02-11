function loading(imgid)
{
  var image = document.getElementById('imagehover');
  image.setAttribute('src', '../../Covers/' + imgid);
  image.setAttribute('class', 'imagehoveron');
  window.onmousemove = function (e) {
  var x = e.clientX,
        y = e.clientY;
    image.style.top = (y + 20) + 'px';
    image.style.left = (x + 20) + 'px';
	}
}
function hide(imgid)
{
  var image = document.getElementById('imagehover');
  image.setAttribute('src', '');
  image.setAttribute('class', 'imagehoveroff');
}
