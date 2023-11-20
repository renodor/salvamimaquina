import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const mainImage = document.querySelector('#product-show #main-image img');
    const thumbnails = document.querySelectorAll('#thumbnails .thumbnail');

    const replaceMainImageSrc = ({ imageUrl, key }) => {
      mainImage.src = imageUrl;
      mainImage.dataset.key = key;
    };

    const setSelectedThumbnail = () => {
      thumbnails.forEach((thumbnail) => {
        if (thumbnail.dataset.key === mainImage.dataset.key) {
          thumbnail.classList.add('selected');
        } else {
          thumbnail.classList.remove('selected');
        }
      });
    };

    thumbnails.forEach((thumbnail) => {
      thumbnail.addEventListener('click', (event) => {
        replaceMainImageSrc(event.currentTarget.dataset);
        setSelectedThumbnail();
      });
    });
  }
}
