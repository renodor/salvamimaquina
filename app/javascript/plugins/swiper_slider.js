// import Swiper JS
import Swiper, { Autoplay, Navigation, Pagination, Manipulation } from 'swiper';
Swiper.use([Autoplay, Navigation, Pagination, Manipulation]); // https://github.com/JayChase/angular2-useful-swiper/issues/48

const swiperSlider = () => {
  const swiperCarousel = document.querySelector('.swiper');

  if (swiperCarousel) {
    const sliderOptions = JSON.parse(swiperCarousel.dataset.sliderOptions);
    const swiper = new Swiper('.swiper', {
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

    if (sliderOptions.disableLoop) { swiper.disable(); }

    const slides = JSON.parse(swiperCarousel.dataset.slides);
    const addRelevantSlides = () => {
      // Because swiper needs at least 1 slide to initiate loop we can't just remove all slides all the time
      // So we 1) add a placeholder > 2) remove all other slides > 3) add new slides > 4) remove placeholder
      swiper.prependSlide('<div class="swiper-slide placeholder-slide">'); // 1)
      swiper.removeSlide([...Array(swiper.slides.length).keys()].slice(1)); // 2)
      swiper.appendSlide(slides.map(({ link, image, imageMobile }) => { // 3)
        return `<div class="swiper-slide centered-flexbox">
          <a href="${link}">
            <img src="${window.innerWidth > 575 ? image : imageMobile || image}" />
          </a>
        </div>`;
      }));
      swiper.removeSlide(0); // 4)
    };
    addRelevantSlides();

    let currentDevice = '';
    const setCurrentDevice = () => (currentDevice = window.innerWidth > 575 ? 'desktop' : 'mobile');
    setCurrentDevice();
    const setSwiperDeviceType = () => (swiper.wrapperEl.dataset.deviceType = currentDevice);
    setSwiperDeviceType();

    swiper.on('breakpoint', () => {
      setCurrentDevice();
      if (currentDevice != swiper.wrapperEl.dataset.deviceType) {
        setSwiperDeviceType();
        addRelevantSlides();
      }
    });
  }
};

export { swiperSlider };

