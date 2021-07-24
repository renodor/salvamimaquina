const priceRangeSlider = () => {
  const priceRangeSlider = document.querySelector('.price-range-slider');

  if (priceRangeSlider) {
    const ranges = priceRangeSlider.querySelectorAll('input[type="range"]');
    const currentValues = priceRangeSlider.querySelectorAll('.current-values span');

    ranges.forEach((range) => {
      range.oninput = () => {
        let slide1 = parseFloat(ranges[0].value);
        let slide2 = parseFloat(ranges[1].value);

        if (slide1 > slide2) {
          [slide1, slide2] = [slide2, slide1];
        }

        currentValues[0].innerHTML= `$${slide1}`;
        currentValues[1].innerHTML= `$${slide2}`;
      };
    });

    // numbers.forEach((number) => {
    //   number.oninput = () => {
    //     const number1 = parseFloat(numbers[0].value);
    //     const number2 = parseFloat(numbers[1].value);

    //     if (number1 > number2) {
    //       const saveNumber = number1;
    //       numbers[0].value = number2;
    //       numbers[1].value = saveNumber;
    //     }

    //     ranges[0].value = number1;
    //     ranges[1].value = number2;
    //   }
    // });
  }
};

export { priceRangeSlider };
