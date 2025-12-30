interface TimelineProps {
  date: string
  title: string
  description?: string
}

const Timeline = ({ content }: {content: TimelineProps[]}) => {
  return (
    <section className="flex flex-col w-full max-w-[800px]">
      <div className="relative border-l-2 border-slate-700 ml-6">
        {content.map((item) => (
          <div key={item.title.replaceAll(" ", "")} className="relative mb-10 ml-6">
            <div className="absolute w-3 h-3 bg-slate-700 rounded-full -left-[31px]  top-1.6"></div>
            <p className="text-sm text-gray-500">{item.date}</p>
            <h3 className="text-md text-gray-700 dark:text-gray-200 font-semibold">{item.title}</h3>
            {
              item.description ?? <p className="text-gray-600 mt-2">{item.description}</p>
            }
          </div>
        ))}
      </div>
    </section>
  )
}

export default Timeline
