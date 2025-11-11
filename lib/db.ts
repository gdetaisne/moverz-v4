import { PrismaClient } from '@prisma/client';

// Singleton pattern pour éviter trop de connexions en dev
const globalForPrisma = global as unknown as { prisma: PrismaClient };

export const prisma =
  globalForPrisma.prisma ||
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
    // Configuration du connection pool pour éviter "Connection reset by peer"
    datasources: {
      db: {
        url: process.env.DATABASE_URL,
      },
    },
  });

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

// Graceful shutdown : fermer proprement les connexions
const shutdownHandler = async () => {
  console.log('🔌 Closing database connections...');
  await prisma.$disconnect();
  console.log('✅ Database connections closed');
  process.exit(0);
};

// Écouter les signaux de shutdown
if (typeof process !== 'undefined') {
  process.on('SIGINT', shutdownHandler);  // Ctrl+C
  process.on('SIGTERM', shutdownHandler); // Docker/Kubernetes stop
  process.on('beforeExit', async () => {
    await prisma.$disconnect();
  });
}


