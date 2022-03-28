// import Swiper JS
import Swiper, { Autoplay, Navigation, Pagination, Manipulation } from 'swiper';
Swiper.use([Autoplay, Navigation, Pagination, Manipulation]); // https://github.com/JayChase/angular2-useful-swiper/issues/48

const swiperSlider = () => {
  const sliders = document.querySelectorAll('.swiper');

  if (sliders.length > 0) {
    // Set currentDevice variable and slider device type to track when we need to change slides
    let currentDevice = '';
    const setCurrentDevice = () => (currentDevice = window.innerWidth > 575 ? 'desktop' : 'mobile');
    setCurrentDevice();

    // Add slides to slider
    const addRelevantSlides = (slider, slides) => {
      // Because swiper needs at least 1 slide to initiate loop we can't just remove all slides at the same time
      // So we 1) add a placeholder > 2) remove all other slides > 3) add new slides > 4) remove placeholder
      slider.prependSlide('<div class="swiper-slide placeholder-slide">'); // 1)
      slider.removeSlide([...Array(slider.slides.length).keys()].slice(1)); // 2)
      slider.appendSlide(slides.map(({ link, image, imageMobile }) => { // 3)
        return `<div class="swiper-slide centered-flexbox">
          ${link ? `<a href="${link}">` : ''}
            <img src="${window.innerWidth > 575 ? image : imageMobile || image}" />
           ${link ? `</a>` : ''}
        </div>`;
      }));
      slider.removeSlide(0); // 4)
    };

    const setSwiperDeviceType = (slider) => (slider.wrapperEl.dataset.deviceType = currentDevice);

    // When window is resized and we pass a breakpoint, change slides (desktop VS mobile) if needed
    const changeSlidesOnWindowsResize = (slider, slides) => {
      slider.on('breakpoint', () => {
        setCurrentDevice();
        if (currentDevice != slider.wrapperEl.dataset.deviceType) {
          setSwiperDeviceType(slider);
          addRelevantSlides(slider, slides);
        }
      });
    };

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
          }
        }
      });
      if (sliderOptions.disableLoop) { swiperSlider.disable(); }

      // Get slide infos from HTML view
      const slides = JSON.parse(slider.dataset.slides);

      setSwiperDeviceType(swiperSlider);
      addRelevantSlides(swiperSlider, slides);
      changeSlidesOnWindowsResize(swiperSlider, slides);
    });
  }
};

export { swiperSlider };

