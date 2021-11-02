# Introduction

I'm following along [here](https://dev.to/dabit3/building-scalable-full-stack-apps-on-ethereum-with-polygon-2cfb) and logging my progress. The guide says that we'll be building an NFT marketplace that can handle minting and collecting using Polygon (MATIC).

# Setup

## Next.js

We'll be using next.js for the skeleton of our application

```bash
$ npx create-next-app digital-marketplace
```

You should see the output:

```bash
Success! Created digital-marketplace at ethereum-tutorials/digital-marketplace
Inside that directory, you can run several commands:

  npm run dev
    Starts the development server.

  npm run build
    Builds the app for production.

  npm start
    Runs the built app in production mode.

We suggest that you begin by typing:

  cd digital-marketplace
  npm run dev
```

We'll be installing a few more dependencies inside the project directory:

```bash
$ cd digital-marketplace
$ npm install ethers hardhat @nomiclabs/hardhat-waffle \
    ethereum-waffle chai @nomiclabs/hardhat-ethers \
    web3modal @openzeppelin/contracts ipfs-http-client@50.1.2 \
    axios
```

## TailwindCSS

And also setting up [TailwindCSS](https://tailwindcss.com/). The guide mentions that this is a popular utility for setting up good looking websites without too much effort. I believe it's a common pairing to Next.js websites too.

```bash
$ npm install -D tailwindcss@latest postcss@latest autoprefixer@latest
```

And then initialize TailwindCSS files:

```bash
$ npx tailwindcss init -p
```

which should say that two files have been created:

```bash
Created Tailwind CSS config file: tailwind.config.js
Created PostCSS config file: postcss.config.js
```

Lastly, the guide says to delete the contents of `styles/globals.css` and replace it with:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

# Next.js README

This is a [Next.js](https://nextjs.org/) project bootstrapped with [`create-next-app`](https://github.com/vercel/next.js/tree/canary/packages/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `pages/index.js`. The page auto-updates as you edit the file.

[API routes](https://nextjs.org/docs/api-routes/introduction) can be accessed on [http://localhost:3000/api/hello](http://localhost:3000/api/hello). This endpoint can be edited in `pages/api/hello.js`.

The `pages/api` directory is mapped to `/api/*`. Files in this directory are treated as [API routes](https://nextjs.org/docs/api-routes/introduction) instead of React pages.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js/) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/deployment) for more details.
