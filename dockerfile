ARG NODE_VERSION=20.19.0

# Build Stage
FROM node:${NODE_VERSION}-slim AS build

# Enable pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && corepack prepare pnpm@9.14.4 --activate

# Set working directory
WORKDIR /app

#  Copy package.json and pnpm-lock.yaml files to the working directory
COPY package.json ./
COPY pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --shamefully-hoist --frozen-lockfile

# Copy the rest of the application to the working directory
COPY . .

# Build the Nuxt application to generate .output
RUN pnpm run build

# Create a new stage for the production image
FROM node:${NODE_VERSION}-slim AS production

# Set working directory
WORKDIR /app

# Copy the output from the build stage to the production stage
COPY --from=build /app/.output ./.output

# Define the environment variables
ENV HOST=0.0.0.0 NODE_ENV=production   

# Expose the application port
EXPOSE 3000

# Start the application
CMD ["node", ".output/server/index.mjs"]