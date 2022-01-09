// import Swiper JS
import Swiper, { Autoplay, Navigation, Pagination } from 'swiper';
Swiper.use([Autoplay, Navigation, Pagination]); // https://github.com/JayChase/angular2-useful-swiper/issues/48

const swiperSlider = () => {
  const swiperCarousel = document.querySelector('.swiper');

  if (swiperCarousel) {
    const swiperOptions = swiperCarousel.dataset;
    const swiper = new Swiper('.swiper', {
      loop: swiperCarousel.dataset.loop === 'true',
      spaceBetween: 10,

      navigation: swiperOptions.navigation === 'true' ? { nextEl: '.swiper-next', prevEl: '.swiper-prev' } : false,
      pagination: swiperOptions.pagination === 'true' ? { el: '.swiper-pagination', clickable: true } : false,

      autoplay: {
        enabled: swiperOptions.autoplay === 'true',
        delay: parseInt(swiperOptions.delayBetweenSlides),
        disableOnInteraction: false
      },

      breakpoints: {
        576: {
          slidesPerView: parseInt(swiperOptions.imagePerSlideS)
        },
        768: {
          slidesPerView: parseInt(swiperOptions.imagePerSlideM)
        },
        992: {
          slidesPerView: parseInt(swiperOptions.imagePerSlideL)
        },
        1200: {
          slidesPerView: parseInt(swiperOptions.imagePerSlideXl)
        }
      }
    });

    // const displayRelevantSlides = () => {
    //   const desktopSlides = swiperCarousel.querySelector('.desktop-slides');
    //   const mobileSlides = swiperCarousel.querySelector('.mobile-slides');
    //   if (window.innerWidth >= 767) {
    //     mobileSlides.classList.remove('swiper-wrapper');
    //     mobileSlides.classList.add('display-none');

    //     desktopSlides.classList.add('swiper-wrapper');
    //     desktopSlides.classList.remove('display-none');
    //   } else {
    //     desktopSlides.classList.remove('swiper-wrapper');
    //     desktopSlides.classList.add('display-none');

    //     mobileSlides.classList.add('swiper-wrapper');
    //     mobileSlides.classList.remove('display-none');
    //   }
    // };

    // displayRelevantSlides();
    // window.addEventListener('resize', () => {
    //   displayRelevantSlides();
    // });
  }
};

export { swiperSlider };

