const sliderForm = () => {
  const sliderForm = document.getElementById('slider-form');

  if (sliderForm) {
    // Method that add a listener in photo input to display the image when a file is uploaded
    const initPreviewImageOnFileSelect = (photoInput) => {
      photoInput.addEventListener('change', () => {
        const photoPreview = sliderForm.querySelector(`#${photoInput.dataset.type}-slides .photo-preview[data-id='${photoInput.dataset.id}']`);
        if (photoInput.files && photoInput.files[0]) {
          const reader = new FileReader();
          reader.onload = (event) => { photoPreview.src = event.currentTarget.result; };
          reader.readAsDataURL(photoInput.files[0]);
          photoPreview.classList.remove('display-none');
        }
      });
    };

    // Method that add a listener on remove slide btn to remove it from the DOM when clicked
    const initRemoveSlideBtn = (removeSlideBtn) => {
      removeSlideBtn.addEventListener('click', (event) => {
        const currentPhotoInputContainer = event.currentTarget.parentNode;
        const photoInputContainers = sliderForm.querySelectorAll('.photo-input-container');

        if (photoInputContainers.length === 1) {
          currentPhotoInputContainer.classList.add('display-none');
        } else {
          currentPhotoInputContainer.remove();
        }
      });
    };

    // Init all photo inputs present on the page
    sliderForm.querySelectorAll('.photo-input').forEach((photoInput) => initPreviewImageOnFileSelect(photoInput));

    // Init all remove slide btn present on the page
    sliderForm.querySelectorAll('.remove-slide').forEach((removeSlideBtn) => {
      initRemoveSlideBtn(removeSlideBtn);
    });

    // Add a new slide container on the DOM when clicking on add slide btn
    sliderForm.querySelectorAll('.add-slide').forEach((addSlideBtn) => {
      addSlideBtn.addEventListener('click', (event) => {
        const photoInputContainers = sliderForm.querySelectorAll(`#${event.currentTarget.dataset.type}-slides .photo-input-container`);
        const lastPhotoInputContainer = photoInputContainers[photoInputContainers.length - 1]; // Always select the last one to have the last ID

        const newPhotoInputContainer = lastPhotoInputContainer.cloneNode(true);
        const newPhotoInput = newPhotoInputContainer.querySelector('.photo-input');
        const newPhotoPreview = newPhotoInputContainer.querySelector('.photo-preview');
        const removeSlideBtn = newPhotoInputContainer.querySelector('.remove-slide');
        const newId = parseInt(newPhotoInput.dataset.id) + 1;

        newPhotoInput.dataset.id = newId;
        newPhotoPreview.dataset.id = newId;
        newPhotoInput.value = null;
        newPhotoPreview.src = '';
        removeSlideBtn.classList.remove('display-none');
        lastPhotoInputContainer.classList.remove('display-none');

        initPreviewImageOnFileSelect(newPhotoInput);
        initRemoveSlideBtn(removeSlideBtn);
        lastPhotoInputContainer.after(newPhotoInputContainer);
      });
    });

    sliderForm.querySelectorAll('.remove-existing-slide').forEach((existingSlide) => {
      existingSlide.addEventListener('click', (event) => { event.currentTarget.parentNode.remove(); });
    });
  }
};

export { sliderForm };
