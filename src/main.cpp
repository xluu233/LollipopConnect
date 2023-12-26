#include <iostream>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include "src/util/SettingsHelper.h"
#include "src/log/Log.h"
#include "src/component/CircularReveal.h"
#include "src/component/FileWatcher.h"
#include "src/component/FpsItem.h"
#include <QQmlContext>

void initQmlType()
{
    qmlRegisterType<CircularReveal>("lcomponent", 1, 0, "CircularReveal");
    qmlRegisterType<FileWatcher>("lcomponent", 1, 0, "FileWatcher");
    qmlRegisterType<FpsItem>("lcomponent", 1, 0, "FpsItem");
}

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    SettingsHelper::getInstance()->init(argv);
    Log::setup("LCONNECT");

    if(SettingsHelper::getInstance()->getRender()=="software")
    {
#if (QT_VERSION >= QT_VERSION_CHECK(6, 0, 0))
        QQuickWindow::setGraphicsApi(QSGRendererInterface::Software);
#elif (QT_VERSION >= QT_VERSION_CHECK(5, 14, 0))
        QQuickWindow::setSceneGraphBackend(QSGRendererInterface::Software);
#endif
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("SettingsHelper",SettingsHelper::getInstance());
    initQmlType();

//    const QUrl url(QStringLiteral("qrc:/lconnect/qml/main.qml"));
    const QUrl url(u"qrc:/lconnect/qml/App.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                if (!obj && url == objUrl)
                    QCoreApplication::exit(-1);
            }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
