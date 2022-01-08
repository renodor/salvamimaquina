const sliderForm = () => {
  const sliderForm = document.getElementById('slider-form');

  if (sliderForm) {
    const previewImageOnFileSelect = (photoInput) => {
      photoInput.addEventListener('change', () => {
        const id = photoInput.dataset.id;
        console.log(id);
        // we call the displayPreview function (who retrieve the image url and display it)
        if (photoInput.files && photoInput.files[0]) {
          const reader = new FileReader();
          reader.onload = (event) => {
            document.getElementById('photo-preview').src = event.currentTarget.result;
          };
          reader.readAsDataURL(photoInput.files[0]);
          document.getElementById('photo-preview').classList.remove('display-none');
        }
      });
    };

    sliderForm.querySelectorAll('.photo-input').forEach((photoInput) => previewImageOnFileSelect(photoInput));

    const addSlideBtn = sliderForm.querySelector('#add-slide');

    addSlideBtn.addEventListener('click', () => {
      const photoInputContainers = sliderForm.querySelectorAll('.photo-input-container');
      const lastPhotoInputContainer = photoInputContainers[photoInputContainers.length - 1];
      const newPhotoInputContainer = lastPhotoInputContainer.cloneNode(true);
      const newPhotoInput = newPhotoInputContainer.querySelector('.photo-input');
      const newId = parseInt(newPhotoInput.dataset.id) + 1;
      newPhotoInput.dataset.id = newId;
      newPhotoInput.id = `slide_images_${newId}`;
      newPhotoInput.files = null
      newPhotoInputContainer.querySelector('label').htmlFor = `slide_images_${newId}`;
      newPhotoInputContainer.querySelector('#photo-preview').dataset.id = newId;
      lastPhotoInputContainer.after(newPhotoInputContainer);
      previewImageOnFileSelect(newPhotoInput);
    });
  }
};

export { sliderForm };
