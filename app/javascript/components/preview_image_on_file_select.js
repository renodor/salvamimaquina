// When uploading an image to a form, display a preview of it next to the form input
const previewImageOnFileSelect = () => {
  const formWithImages = document.querySelector('.form-with-images');

  if (formWithImages) {
    formWithImages.querySelectorAll('.image-input input').forEach((imageInput) => {
      imageInput.addEventListener('change', () => {
        const imagePreview = formWithImages.querySelector(`.image-preview[data-id='${imageInput.dataset.id}']`);
        if (imageInput.files && imageInput.files[0]) {
          const reader = new FileReader();
          reader.onload = (event) => { imagePreview.src = event.currentTarget.result; };
          reader.readAsDataURL(imageInput.files[0]);
          imagePreview.classList.remove('display-none');
        }
      });
    });
  }
};

export { previewImageOnFileSelect };
