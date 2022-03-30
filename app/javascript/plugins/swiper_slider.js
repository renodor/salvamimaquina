// import Swiper JS: https://swiperjs.com/
import Swiper, { Autoplay, Navigation, Pagination, Manipulation } from 'swiper';
Swiper.use([Autoplay, Navigation, Pagination, Manipulation]); // https://github.com/JayChase/angular2-useful-swiper/issues/48

const swiperSlider = () => {
  const sliders = document.querySelectorAll('.swiper');

  if (sliders.length > 0) {
    // Add slides to slider
    const addRelevantSlides = (slider, slides) => {
      // Because swiper needs at least 1 slide to initiate loop we can't just remove all slides at the same time
      // So we 1) add a placeholder > 2) remove all other slides > 3) add new slides > 4) remove placeholder
      slider.prependSlide('<div class="swiper-slide placeholder-slide">'); // 1)
      slider.removeSlide([...Array(slider.slides.length).keys()].slice(1)); // 2)
      slider.appendSlide(slides.map(({ link, images, imageMobile }) => { // 3)
        return `<div class="swiper-slide centered-flexbox">
          ${link ? `<a href="${link}">` : ''}
            <img src="${images[slider.currentBreakpoint]}" />
          ${link ? `</a>` : ''}
        </div>`;
      }));
      slider.removeSlide(0); // 4)
    };

    // Generate sliders with correct options for all DOM elements that have the .swiper class
    sliders.forEach((slider) => {
      // Get slider options from HTML view
      const sliderOptions = JSON.parse(slider.dataset.sliderOptions);

      // Initialize swiper instance with the slider options
      const swiperSlider = new Swiper(`.swiper[data-slider-id="${slider.dataset.sliderId}"]`, {
        loop: true,
        spaceBetween: sliderOptions.spaceBetweenSlides,

        navigation: sliderOptions.navigation ? { nextEl: '.swiper-next', prevEl: '.swiper-prev' } : false,
        pagination: sliderOptions.pagination ? { el: '.swiper-pagination', clickable: true } : false,

        autoplay: {
          enabled: sliderOptions.autoplay,
          delay: sliderOptions.delayBetweenSlides,
          disableOnInteraction: false
        },

        breakpoints: {
          576: {
            slidesPerView: sliderOptions.imagePerSlideS
          },
          768: {
            slidesPerView: sliderOptions.imagePerSlideM
          },
          992: {
            slidesPerView: sliderOptions.imagePerSlideL
          },
          1200: {
            slidesPerView: sliderOptions.imagePerSlideXl
          },
          1400: { // We don't use this breakpoint for imagePerSlide config, but use it to display the slide image at the correct size
            slidesPerView: sliderOptions.imagePerSlideXl
          }
        }
      });
      if (sliderOptions.disableLoop) { swiperSlider.disable(); }

      // Get slide data from HTML view
      const slides = JSON.parse(slider.dataset.slides);

      addRelevantSlides(swiperSlider, slides);
      // Whenever windows size hit a new breakpoint, update sliders with slides of the correct size
      swiperSlider.on('breakpoint', () => (addRelevantSlides(swiperSlider, slides)));
    });
  }
};

export { swiperSlider };

