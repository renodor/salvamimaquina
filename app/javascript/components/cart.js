const cart = () => {
  const cart = document.getElementById('cart-detail');
  if (cart) {
  //   const lineItems = cart.querySelectorAll('.line-item');
  //   lineItems.forEach((lineItem) => {
  //     const lineItemId = lineItem.dataset.id;
  //     const cartItemDelete = lineItem.querySelector('.cart-item-delete');
  //     cartItemDelete.addEventListener('click', (event) => {
  //       fetch(`api/orders/${gon.order_info.number}/line_items/${lineItemId}`, {
  //         method: 'DELETE',
  //         headers: {
  //           'X-Spree-Order-Token': gon.order_info.guest_token,
  //           'accept': 'application/json'
  //         }
  //       })
  //         .then((response) => response.json())
  //         .then(({ lineItem }) => {
  //           removeLineItem(lineItem.id);
  //           updateOrderInfo()
  //         });
  //     })
  //   })

    //   const removeLineItem = (id) => {
    //     cart.querySelector(`.line-item[data-id="${id}"]`).remove()
    //   }

  //   const updateOrderInfo = () => {
  //     fetch(`api/orders/${gon.order_info.number}`, {
  //       headers: {
  //         'X-Spree-Order-Token': gon.order_info.guest_token,
  //         'accept': 'application/json'
  //       }
  //     })
  //       .then((response) => response.json())
  //       .then((data) => {
  //         debugger
  //       });
  //   }
  }
};

export { cart };
