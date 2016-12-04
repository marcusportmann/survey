/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.web.data;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.ISurveyService;
import digital.survey.model.SurveyAudience;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.data.InjectableDataProvider;
import guru.mmp.common.util.StringUtil;
import org.apache.wicket.model.IModel;

import javax.inject.Inject;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>FilteredSurveyAudienceDataProvider</code> class provides an <code>IDataProvider</code>
 * implementation that retrieves <code>SurveyAudience</code> instances from the database.
 *
 * @author Marcus Portmann
 */
public class FilteredSurveyAudienceDataProvider extends InjectableDataProvider<SurveyAudience>
{
  private static final long serialVersionUID = 1000000;

  /**
   * The filter used to limit the matching survey audiences.
   */
  private String filter = "";

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the organisation the survey
   * audiences are associated with.
   */
  private UUID organisationId;

  /**
   * Constructs a new <code>FilteredSurveyAudienceDataProvider</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected FilteredSurveyAudienceDataProvider() {}

  /**
   * Constructs a new <code>FilteredSurveyAudienceDataProvider</code>.
   *
   * @param organisationId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                       organisation the survey audiences are associated with
   */
  public FilteredSurveyAudienceDataProvider(UUID organisationId)
  {
    this.organisationId = organisationId;
  }

  /**
   * @see org.apache.wicket.model.IDetachable#detach()
   */
  public void detach() {}

  /**
   * Returns the filter used to limit the matching survey audiences.
   *
   * @return the filter used to limit the matching survey audiences
   */
  @SuppressWarnings("unused")
  public String getFilter()
  {
    return filter;
  }

  /**
   * Retrieves the matching survey audiences from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>.
   *
   * @param first the index of the first entry to return
   * @param count the number of the entries to return
   *
   * @return the survey audiences retrieved from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#iterator(long, long)
   */
  public Iterator<SurveyAudience> iterator(long first, long count)
  {
    try
    {
      List<SurveyAudience> allSurveyAudiences = StringUtil.isNullOrEmpty(filter)
          ? surveyService.getSurveyAudiencesForOrganisation(organisationId)
          : surveyService.getFilteredSurveyAudiencesForOrganisation(organisationId, filter);

      return allSurveyAudiences.subList((int) first, (int) Math.min(first + count,
          allSurveyAudiences.size())).iterator();
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to load the survey audiences for the organisation (%s)"
          + " matching the filter (%s) from index (%d) to (%d)", organisationId, filter, first,
          first + count - 1), e);
    }
  }

  /**
   * Wraps the retrieved <code>SurveyAudience</code> POJO with a Wicket model.
   *
   * @param surveyAudience the <code>SurveyAudience</code> instance to wrap
   *
   * @return the Wicket model wrapping the <code>SurveyAudience</code> instance
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#model(java.lang.Object)
   */
  public IModel<SurveyAudience> model(SurveyAudience surveyAudience)
  {
    return new DetachableSurveyAudienceModel(surveyAudience);
  }

  /**
   * Set the filter used to limit the matching survey audiences.
   *
   * @param filter the filter used to limit the matching survey audiences
   */
  public void setFilter(String filter)
  {
    this.filter = filter;
  }

  /**
   * Returns the total number of survey audiences.
   *
   * @return the total number of survey audiences
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#size()
   */
  public long size()
  {
    try
    {
      return StringUtil.isNullOrEmpty(filter)
          ? surveyService.getNumberOfSurveyAudiencesForOrganisation(organisationId)
          : surveyService.getNumberOfFilteredSurveyAudiencesForOrganisation(organisationId, filter);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(
          "Failed to retrieve the number of survey audiences for the organisation ("
          + organisationId + ") matching the filter (" + filter + ")", e);
    }
  }
}
