# Salva Mi Máquina Ecommerce Webapp

<img src="app/assets/images/logo-smm.png" width="300">

This is the showcase website and Ecommerce platform of Salva Mi Máquina, a company that sells and repairs smartphones, tablets, and computers.

Salva Mi Máquina uses an entreprise resource planning (ERP) software called [RepairShopr](https://www.repairshopr.com/){:target="_blank"}} to manage, among other things, their products (inventory, prices, skus, images, descriptions etc..), their invoices, their client database... One of the biggest challenges of this project was to integrate RepairShopr with the Ecommerce so that both platforms are automatically synchronized:
* Creating a new product on RepairShopr will automatically create it on the Ecommerce
* Making a purchase on the Ecommerce will automatically create an invoice on RepairShopr
* Inventory levels are synchronized between both platforms in real time
* etc...

[Go to production website](https://www.salvamimaquina.com/)

### Built With
* [Ruby on Rails](https://rubyonrails.org/)
* [Solidus](https://solidus.io/)
* [Bootstrap](https://getbootstrap.com/)

### Aditional plugins
* [Sidekiq](https://sidekiq.org/) (Background jobs)
* [Sentry](https://sentry.io/) (Exceptions and errors management)
* [Cloudinary](https://cloudinary.com/) (Images management)
* [Postmark](https://postmarkapp.com/) (Email delivery service)
