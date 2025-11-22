#pragma once
#include <QObject>
#include <QThreadPool>
#include <QVariant>
#include <QMutex>
#include <QHash>

class DownloadTask;

class DownloadEngine : public QObject
{
    Q_OBJECT
public:
    explicit DownloadEngine(QObject* parent = nullptr);
    ~DownloadEngine();

    void download(const QString& url, const QString& saveDir, const QVariant& userData);
    void cancelDownload(const QVariant& userData);
    void cancelAll();

    int activeDownloads() const;
    int maxThreadCount() const;
    void setMaxThreadCount(int count);
    void setResumeExisting(bool enabled) { m_resumeExisting = enabled; }

    void waitForAllFinished();

signals:
    void downloadProgress(qint64 bytesReceived, qint64 bytesTotal, const QVariant& userData);
    void downloadFinished(bool success, const QString& errorString, const QVariant& userData);
    void allDownloadFinished();

private slots:
    void onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal, const QVariant& userData);
    void onDownloadFinished(bool success, const QString& errorString, const QVariant& userData);

private:
    QThreadPool m_threadPool;
    QHash<QVariant, DownloadTask*> m_activeDownloads;
    bool m_resumeExisting = true;
    mutable QMutex m_mutex;
};
