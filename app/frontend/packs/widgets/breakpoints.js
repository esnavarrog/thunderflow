const breakpointsList = {
  xxs: 0,
  xs: 395,
  sm: 576,
  md: 768,
  lg: 992,
  xl: 1200,
  xxl: 1400,
}

const breakpointsListKeys = Object.keys(breakpointsList);

export function breakpointUp(breakpoint) {
  return $(window).width() > breakpointsList[breakpoint]
}

export function breakpointDown(breakpoint) {
  return $(window).width() < breakpointsList[breakpoint]
}

export function breakpointBetween(...breakpoints) {
  const [firstBreakpointIndex, secondBreakpointIndex] = breakpoints.map((breakpoint)  => breakpointsListKeys.findIndex(key => key === breakpoint))

  if (firstBreakpointIndex === undefined || secondBreakpointIndex === undefined) return null
  if (firstBreakpointIndex === -1 || secondBreakpointIndex === -1) return null
  if (firstBreakpointIndex === 0) return true
  return breakpointUp(breakpointsListKeys[firstBreakpointIndex - 1 ]) && breakpointDown(breakpointsListKeys[secondBreakpointIndex + 1])
}