const productShowThumbnails = () => {
  const thumbnailsContainer = document.querySelectorAll('#product-show #thumbnails');

  if (thumbnailsContainer) {
    const mainImage = document.querySelector('#product-show #main-image img');
    const thumbnails = document.querySelectorAll('#thumbnails .thumbnail');

    const replaceMainImageSrc = (newImageUrl) => {
      mainImage.src = newImageUrl;
    };

    thumbnails.forEach((thumbnail) => {
      thumbnail.addEventListener('click', (event) => {
        const selectedThumbnail = event.currentTarget;
        selectedThumbnail.classList.add('selected');
        thumbnails.forEach((otherThumbnail) => {
          if (otherThumbnail !== selectedThumbnail) {
            otherThumbnail.classList.remove('selected');
          };
        });
        replaceMainImageSrc(selectedThumbnail.dataset.imageUrl);
      });

      thumbnail.addEventListener('mouseover', (event) => {
        replaceMainImageSrc(event.currentTarget.dataset.imageUrl);
      });
    });
  }
};

export { productShowThumbnails };